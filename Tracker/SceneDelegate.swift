import UIKit
import CoreData
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var trackerStore: TrackerStore!
    var trackerRecordStore: TrackerRecordStore!
    var trackerCategoryStore: TrackerCategoryStore!

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        
        trackerStore = TrackerStore(context: persistentContainer.viewContext)
        trackerRecordStore = TrackerRecordStore(context: persistentContainer.viewContext)
        trackerCategoryStore = TrackerCategoryStore(context: persistentContainer.viewContext)
        let tabBarController = TabBarController(
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore,
            trackerCategoryStore: trackerCategoryStore
        )
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = UIColor(resource: .ypWhite)
        window.rootViewController = tabBarController
        
        
        self.window = window
        window.makeKeyAndVisible()
        
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
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

