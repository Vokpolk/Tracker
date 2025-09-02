import CoreData

extension TrackerCategoryCoreData {
    func toStruct() -> TrackerCategory {
        TrackerCategory(
            title: title ?? "",
            trackers: (trackers?.allObjects as? [TrackerCoreData])?.compactMap { $0.toStruct() } ?? []
        )
    }
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    func addNewTrackerCategory(_ trackerCategoryTitle: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = trackerCategoryTitle
        category.trackers = []
        saveContext()
    }
    
    var trackerCategories: [TrackerCategory] {
        guard let trackerCategories = fetchedResultsController.fetchedObjects else { return [] }
        
        var result: [TrackerCategory] = []
        trackerCategories.forEach {
            result.append($0.toStruct())
        }
        return result
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
    
    private func setupFetchedResultsController() {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
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
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        
    }
}
