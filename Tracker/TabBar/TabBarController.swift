import UIKit

final class TabBarController: UITabBarController {
    
    init(trackerStore: TrackerStore,
         trackerRecordStore: TrackerRecordStore,
         trackerCategoryStore: TrackerCategoryStore
    ) {
        
        super.init(nibName: nil, bundle: nil)
        let trackersViewController = TrackersViewController(
            trackerStore: trackerStore,
            trackerRecordStore: trackerRecordStore,
            trackerCategoryStore: trackerCategoryStore
        )
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabBarTracker),
            selectedImage: nil
        )
        
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabBarStat),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersViewController, statisticViewController]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.tabBar.addFullBorder()
        
        
    }
}

extension UITabBar {
    func addFullBorder(color: UIColor = .lightGray, width: CGFloat = 0.5) {
        let borderLayer = CALayer()
        borderLayer.name = "borderLayer"
        borderLayer.backgroundColor = color.cgColor
        
        borderLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: width)
        layer.addSublayer(borderLayer)
    }
}
