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
        self.window = window
        
        trackerStore = (UIApplication.shared.delegate as! AppDelegate).trackerStore
        trackerRecordStore = (UIApplication.shared.delegate as! AppDelegate).trackerRecordStore
        trackerCategoryStore = (UIApplication.shared.delegate as! AppDelegate).trackerCategoryStore
        
        UserDefaults.standard.bool(forKey: OnboardingUserDefaults.shown) ? showTrackers() : showOnboarding()
        
        window.makeKeyAndVisible()
    }
    
    private func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        
        onboardingVC.showTrackers = { [weak self] in
            self?.showTrackers()
            UserDefaults.standard.set(true, forKey: OnboardingUserDefaults.shown)
        }
        window?.rootViewController = onboardingVC
    }
    
    private func showTrackers() {
        let tabBarController = TabBarController(
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore,
            trackerCategoryStore: trackerCategoryStore
        )
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = UIColor(resource: .ypWhite)
        
        tabBarController.view.alpha = 0
        UIView.transition(
            with: tabBarController.view,
            duration: 0.25
        ) {
            self.window?.rootViewController = tabBarController
            tabBarController.view.alpha = 1
        }
    }
}

