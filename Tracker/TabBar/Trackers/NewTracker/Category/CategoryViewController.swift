import UIKit

protocol CategoryDelegate: AnyObject {
    func newCategoryName(_ name: String)
}

final class CategoryViewController: UIViewController {
    
    // MARK: - Private Properties
    private var viewModel: CategoryViewModel?
    private var categories: [TrackerCategory] = []
    private var pickedCategory: String?
    weak var delegate: CategoryDelegate?
    
    private let cellIdentifier = "categoryCell"
    private let cellHeight = 75
    
    private let scrollView: UIScrollView = UIScrollView()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
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
            CategoryCollectionViewCell.self,
            forCellWithReuseIdentifier: cellIdentifier
        )
        collectionView.layer.cornerRadius = 16
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collectionView.clipsToBounds = true
        collectionView.isScrollEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let starImage = UIImage(resource: .dizzy)
        let placeholderImageView = UIImageView(image: starImage)
        return placeholderImageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Привычки и события можно\nобъединить по смыслу"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(Self.createNewCategory),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        viewModel = CategoryViewModel(
            model: (UIApplication.shared.delegate as! AppDelegate).trackerCategoryStore
        )
        viewModel?.updateCategories = { [weak self] in
            guard let self else { return }
            categories = viewModel?.getCategories() ?? []
            collectionView.reloadData()
            if !categories.isEmpty {
                placeholderImageView.isHidden = true
                label.isHidden = true
            }
        }
        
        categories = viewModel?.getCategories() ?? []
        initScrollView()
        initUIObjects()
    }
    
    // MARK: - Private Methods
    private func initScrollView() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func initUIObjects() {
        if !categories.isEmpty {
            placeholderImageView.isHidden = true
            label.isHidden = true
        }
        view.backgroundColor = UIColor(resource: .ypWhite)
        [
            categoryLabel,
            collectionView,
            placeholderImageView,
            label,
            addCategoryButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            categoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            collectionView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
//            collectionView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: CGFloat(cellHeight * categories.count) - 1),
                
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            label.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.heightAnchor.constraint(equalToConstant: 36),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -20),
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc
    private func createNewCategory() {
        guard let viewModel else { return }
        let newCategoryVC = NewCategoryViewController()
        newCategoryVC.initialize(viewModel: viewModel)
        present(newCategoryVC, animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension CategoryViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        categories = viewModel?.getCategories() ?? []
        return categories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? CategoryCollectionViewCell
        
        guard let cell else {
            return UICollectionViewCell()
        }
        cell.contentView.layer.cornerRadius = 0
        cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        cell.separatorView.isHidden = false
        if indexPath.row == 0 {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if indexPath.row == categories.count - 1 {
            cell.contentView.layer.cornerRadius = 16
            cell.contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.separatorView.isHidden = true
        }
        cell.configure(with: categories[indexPath.row].title)
        
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CategoryViewController: UICollectionViewDelegateFlowLayout {
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
        let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell
        guard let cell else { return }
        
        cell.pickCategory(true)
        pickedCategory = categories[indexPath.row].title
        guard let pickedCategory else { return }
        delegate?.newCategoryName(pickedCategory)
        print(pickedCategory)
        dismiss(animated: true)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        let cell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell
        guard let cell else { return }
        
        cell.pickCategory(false)
    }
}
