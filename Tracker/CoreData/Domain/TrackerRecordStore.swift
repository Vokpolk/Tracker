import UIKit
import CoreData

extension TrackerRecordCoreData {
    func toStruct() -> TrackerRecord {
        TrackerRecord(
            id: UInt(id),
            date: date ?? Date()
        )
    }
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func store(
        _ store: TrackerRecordStore
    )
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    weak var delegate: TrackerRecordStoreDelegate?
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    func addNewTrackerRecord(_ record: TrackerRecord) {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = Int32(record.id)
        recordCoreData.date = record.date
        
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.predicate = NSPredicate(format: "id == %ld", Int32(record.id))
        do {
            let trackers = try context.fetch(request)
            if let tracker = trackers.first {
                recordCoreData.tracker = tracker
            }
            
        } catch {
            print("Error finding tracker for record: \(error)")
        }
        
        saveContext()
    }
    
    func removeTrackerRecord(_ id: UInt, with date: Date) {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(
            format: "id == %ld AND date == %@",
            Int32(id), date as CVarArg
        )

        do {
            let trackers = try context.fetch(request)
            let trackerId = trackers[0].objectID
            
            let object = try context.existingObject(with: trackerId)
            context.delete(object)
            saveContext()
        } catch {
            print("Error id object: \(error)")
        }
        
    }
    
    var trackerRecords: [TrackerRecord] {
        guard let trackerRecords = fetchedResultsController.fetchedObjects else { return [] }
        var result: [TrackerRecord] = []
        trackerRecords.forEach {
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
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "id", ascending: true),
            NSSortDescriptor(key: "date", ascending: true)
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

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<any NSFetchRequestResult>
    ) {
        delegate?.store(self)
    }
}
