import UIKit

struct Statistic {
    let title: String
    var number: Int
}

final class StatisticViewController: UIViewController {
    // MARK: Private Properties
    private var data: [Statistic] = [
        //Statistic(title: NSLocalizedString("best period", comment: ""), number: 0),
        //Statistic(title: NSLocalizedString("perfect days", comment: ""), number: 0),
        Statistic(title: NSLocalizedString("trackers completed", comment: ""), number: 0),
        //Statistic(title: NSLocalizedString("average value", comment: ""), number: 0)
    ]
    private let cellHeight = 90
    
    private lazy var statisticLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics", comment: "")//"Статистика"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let cryImage = UIImage(resource: .cryEmoji)
        let placeholderImageView = UIImageView(image: cryImage)
        return placeholderImageView
    }()
    
    private lazy var analizeLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("nothing to analize", comment: "")//"Что будем отслеживать?"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.5
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            StatisticCollectionViewCell.self,
            forCellWithReuseIdentifier: "StatisticCell"
        )
        collectionView.layer.cornerRadius = 16
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collectionView.clipsToBounds = true
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = UIColor(resource: .ypWhite)
        return collectionView
    }()
    
    // MARK: - LyfeCycles
    override func viewDidLoad() {
        initUIObjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if UserDefaults.standard.integer(forKey: "trackers count") != 0 {
            placeholderImageView.isHidden = true
            analizeLabel.isHidden = true
            collectionView.isHidden = false
        } else {
            collectionView.isHidden = true
            placeholderImageView.isHidden = false
            analizeLabel.isHidden = false
        }
        collectionView.reloadData()
    }
    
    // MARK: - Private Methods
    private func initUIObjects() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        
        [
            statisticLabel,
            placeholderImageView,
            analizeLabel,
            collectionView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            statisticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statisticLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            statisticLabel.widthAnchor.constraint(equalToConstant: 254),
            statisticLabel.heightAnchor.constraint(equalToConstant: 41),
            
            placeholderImageView.topAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            analizeLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            analizeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: statisticLabel.bottomAnchor, constant: 77),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
            collectionView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: CGFloat((cellHeight + 12) * data.count)),
            collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

// MARK: - UICollectionViewDataSource
extension StatisticViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StatisticCell", for: indexPath) as? StatisticCollectionViewCell
        guard let cell else {
            return UICollectionViewCell()
        }
        
        var item = data[indexPath.row]
        
        if indexPath.row == 0 {
            item.number = UserDefaults.standard.integer(forKey: "completed trackers")
            
        }
        
        cell.configure(with: item.title, number: item.number)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension StatisticViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 90)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        12
    }
}
