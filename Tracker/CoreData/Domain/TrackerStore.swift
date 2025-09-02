import CoreData

extension TrackerCoreData {
    func toStruct() -> Tracker {
        Tracker(
            id: UInt(id),
            name: name ?? "",
            color: color,
            emoji: emoji ?? "💔",
            weekDays: WeekBitmask.maskToDays(weekDays)
        )
    }
}

protocol TrackerStoreDelegate: AnyObject {
    func store(
        _ store: TrackerStore
    )
}

final class TrackerStore: NSObject {
    let context: NSManagedObjectContext
    weak var delegate: TrackerStoreDelegate?
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    func addNewTracker(_ tracker: Tracker, to categoryName: String) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = Int32(tracker.id)
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.weekDays = WeekBitmask.daysToMask(tracker.weekDays)
        
        let categoryRequest = TrackerCategoryCoreData.fetchRequest()
        categoryRequest.predicate = NSPredicate(format: "title == %@", categoryName)
        categoryRequest.fetchLimit = 1
        
        var categoryCD: TrackerCategoryCoreData?
        if let category = try context.fetch(categoryRequest).first {
            categoryCD = category
        } else {
            categoryCD = TrackerCategoryCoreData(context: context)
            categoryCD?.title = categoryName
        }
        trackerCoreData.category = categoryCD
        
        saveContext()
    }

    var trackers: [Tracker] {
        guard let trackers = fetchedResultsController.fetchedObjects else { return [] }
        var result: [Tracker] = []
        trackers.forEach {
            result.append($0.toStruct())
        }
        return result
    }
    
    func countFetch() -> UInt {
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
            
        do {
            let count = try context.count(for: fetchRequest)
            print(count)
            return UInt(count)
        } catch {
            print("Error counting objects: \(error)")
            return 0
        }
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        controller.delegate = self
        self.fetchedResultsController = controller
        
        do {
            try controller.performFetch()
        } catch {
            fatalError("ERROR")
        }
    }
    
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        delegate?.store(self)
    }
}
