import UIKit

final class LeftViewController: UIViewController {
    lazy var backgroundImage: UIImageView = {
        let onboardImage = UIImage(resource: .onboard1)
        let onboardImageView = UIImageView(image: onboardImage)
        onboardImageView.contentMode = .scaleAspectFill
        return onboardImageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("track only what you want", comment: "")//"Отслеживайте только то, что хотите"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUIObjects()
    }
    
    private func initUIObjects() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        [
            backgroundImage,
            label
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 60)
        ])
    }
}
