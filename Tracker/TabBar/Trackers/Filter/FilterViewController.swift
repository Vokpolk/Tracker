import UIKit

enum PickedFilter {
    static let filter: String = "filter"
    
    static let allTrackers: String = "all trackers"
    static let trackersForToday: String = "trackers for today"
    static let completedTrackers: String = "completed"
    static let notCompletedTrackers: String = "not completed"
}

struct FilterList {
    let title: String
    var isPicked: Bool
}
final class FilterViewController: UIViewController {
    
    // MARK: - Private Properties
    private let cellIdentifier = "filterCell"
    private let cellHeight = 75
    private var pickedFilter: String?
    weak var delegate: FilterDelegate?
    
    private var data: [FilterList] = [
        FilterList(title: NSLocalizedString("all trackers", comment: ""), isPicked: false),
        FilterList(title: NSLocalizedString("trackers for today", comment: ""), isPicked: false),
        FilterList(title: NSLocalizedString("completed", comment: ""), isPicked: false),
        FilterList(title: NSLocalizedString("not completed", comment: ""), isPicked: false)
    ]
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.5
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            FilterCollectionViewCell.self,
            forCellWithReuseIdentifier: cellIdentifier
        )
        collectionView.layer.cornerRadius = 16
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collectionView.clipsToBounds = true
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var filterLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filters", comment: "")//"Новая привычка"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        view.backgroundColor = .white
        addUIElements()
    }
    
    // MARK: - Public Methods
    func initFilter(_ indexName: String) {
        pickedFilter = indexName
    }
    
    
    // MARK: - Private Methods
    private func addUIElements() {
        [
            filterLabel,
            collectionView
        ].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            filterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            collectionView.topAnchor.constraint(equalTo: filterLabel.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
            collectionView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: CGFloat(cellHeight * data.count) - 1),
        ])
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func pickFilter() {
        let indexName = pickedFilter
        if indexName == "all trackers" {
            
        } else if indexName == "trackers for today" {
            
        } else if indexName == "completed" {
            let indexPath = IndexPath(item: 2, section: 0)
            
            collectionView.selectItem(
                at: indexPath,
                animated: false,
                scrollPosition: .centeredHorizontally
            )
            
            collectionView.delegate?.collectionView?(
                collectionView,
                didSelectItemAt: indexPath
            )
        } else if indexName == "not completed" {
            let indexPath = IndexPath(item: 3, section: 0)
            
            collectionView.selectItem(
                at: indexPath,
                animated: false,
                scrollPosition: .centeredHorizontally
            )
            
            collectionView.delegate?.collectionView?(
                collectionView,
                didSelectItemAt: indexPath
            )
        }
    }
}

// MARK: - UICollectionViewDataSource
extension FilterViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return data.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? FilterCollectionViewCell
        guard let cell else {
            return UICollectionViewCell()
        }
        
        let item = data[indexPath.item]
        
        cell.configure(with: item.title)
        
        if pickedFilter == "completed" && cell.titleLabel.text == NSLocalizedString("completed", comment: "") {
            cell.pickFilter(true, title: NSLocalizedString("completed", comment: ""))
        }
        if pickedFilter == "not completed" && cell.titleLabel.text == NSLocalizedString("not completed", comment: "") {
            cell.pickFilter(true, title: NSLocalizedString("not completed", comment: ""))
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 75)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
    // MARK: - Выделение ячейки
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell
        guard let cell else { return }
        guard let titleLabel = cell.titleLabel.text else { return }
        cell.pickFilter(true, title: titleLabel)
        pickedFilter = data[indexPath.row].title
        guard let pickedFilter else { return }
        delegate?.newFilter(pickedFilter)
        dismiss(animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell
        guard let cell else { return }
        guard let titleLabel = cell.titleLabel.text else { return }
        cell.pickFilter(false, title: titleLabel)
    }
}
