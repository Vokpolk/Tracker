import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        self.tabBar.addFullBorder()
        
        let trackersViewController = TrackersViewController()
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
}

extension UITabBar {
    func addFullBorder(color: UIColor = .lightGray, width: CGFloat = 0.5) {
        // Создаем новый слой для границы
        let borderLayer = CALayer()
        borderLayer.name = "borderLayer"
        borderLayer.backgroundColor = color.cgColor
        
        // Верхняя граница
        borderLayer.frame = CGRect(x: 0, y: 0, width: frame.width, height: width)
        layer.addSublayer(borderLayer)
    }
}
