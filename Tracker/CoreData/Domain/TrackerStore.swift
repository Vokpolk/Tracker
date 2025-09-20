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
    
    func deleteTracker(with id: Int32) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id as CVarArg)
        fetchRequest.fetchLimit = 1
        do {
            let results = try context.fetch(fetchRequest)
            if let itemToDelete = results.first {
                context.delete(itemToDelete)
                saveContext()
            }
        } catch {
            print("Ошибка при удалении категории!")
        }
    }
    
    func updateTracker(_ tracker: Tracker, to categoryName: String) throws {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", tracker.id as CVarArg)
        
        
        
        
        
//        var categoryCD: TrackerCategoryCoreData?
//        if let category = try context.fetch(categoryRequest).first {
//            categoryCD = category
//        } else {
//            categoryCD = TrackerCategoryCoreData(context: context)
//            categoryCD?.title = categoryName
//        }
//        let trackerCoreData = TrackerCoreData(context: context)
//        trackerCoreData.category = categoryCD
        
        do {
            let results = try context.fetch(fetchRequest)
            if let objectToUpdate = results.first {
                objectToUpdate.name = tracker.name
                objectToUpdate.emoji = tracker.emoji
                objectToUpdate.weekDays = WeekBitmask.daysToMask(tracker.weekDays)
                objectToUpdate.color = tracker.color
                
                if let oldCategory = objectToUpdate.category {
                    oldCategory.removeFromTrackers(objectToUpdate)
                }
                
                let categoryRequest = TrackerCategoryCoreData.fetchRequest()
                categoryRequest.predicate = NSPredicate(format: "title == %@", categoryName)
                categoryRequest.fetchLimit = 1
                if let newCategory = try context.fetch(categoryRequest).first {
                    newCategory.addToTrackers(objectToUpdate)
                }
                
                try context.save()
                print("Данные успешно обновлены")
            }
        } catch {
            print("Ошибка обновления")
        }
        
        
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
