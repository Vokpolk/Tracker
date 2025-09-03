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
    
    func isCategoryExists(with title: String) -> Bool {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Ошибка при проверке существования категории!")
            return false
        }
    }
    
    func deleteCategory(with title: String) -> Bool {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", title)
        fetchRequest.fetchLimit = 1
        do {
            let results = try context.fetch(fetchRequest)
            if let itemToDelete = results.first {
                context.delete(itemToDelete)
                saveContext()
                return true
            }
            return false
        } catch {
            print("Ошибка при удалении категории!")
            return false
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
