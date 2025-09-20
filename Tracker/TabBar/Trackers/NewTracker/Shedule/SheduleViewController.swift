import UIKit

struct WeekShedule {
    let title: String
    var isOn: Bool
}

final class SheduleViewController: UIViewController {
    
    // MARK: - Private Properties
    private var data: [WeekShedule] = [
        WeekShedule(title: NSLocalizedString("monday", comment: ""), isOn: false),
        WeekShedule(title: NSLocalizedString("tuesday", comment: ""), isOn: false),
        WeekShedule(title: NSLocalizedString("wednesday", comment: ""), isOn: false),
        WeekShedule(title: NSLocalizedString("thursday", comment: ""), isOn: false),
        WeekShedule(title: NSLocalizedString("friday", comment: ""), isOn: false),
        WeekShedule(title: NSLocalizedString("saturday", comment: ""), isOn: false),
        WeekShedule(title: NSLocalizedString("sunday", comment: ""), isOn: false)
    ]
    private let cellHeight = 75
    
    private let scrollView = UIScrollView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.5
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            SheduleCollectionViewCell.self,
            forCellWithReuseIdentifier: "SwitchCell"
        )
        collectionView.layer.cornerRadius = 16
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collectionView.clipsToBounds = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var sheduleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("shedule", comment: "")//"Расписание"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("ready", comment: "")/*"Готово"*/, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypBlack)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(Self.readyButtonTap),
            for: .touchUpInside
        )
        return button
    }()
    
    private weak var delegate: SheduleDelegate?
    // MARK: - Initializers
     init(delegate: SheduleDelegate? = nil) {
         self.delegate = delegate
         super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        
        setupScrollView()
        addUIElements()
    }
    
    // MARK: - Private Methods
    private func setupScrollView() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func addUIElements() {
        [
            sheduleLabel,
            collectionView,
            readyButton
        ].forEach {
            scrollView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            sheduleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            sheduleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            collectionView.topAnchor.constraint(equalTo: sheduleLabel.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant:  -16),
            collectionView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: CGFloat(cellHeight * data.count) - 1),
            collectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            readyButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            readyButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
            readyButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            readyButton.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc private func readyButtonTap() {
        print("ready button tapped")
        delegate?.getWeekDays(data)
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDataSource
extension SheduleViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwitchCell", for: indexPath) as? SheduleCollectionViewCell
        guard let cell else {
            return UICollectionViewCell()
        }
        
        let item = data[indexPath.item]
        
        cell.configure(with: item.title, isOn: item.isOn)
        cell.cellSwitch.tag = indexPath.item
        cell.cellSwitch.addTarget(
            self,
            action: #selector(Self.switchValueChanged),
            for: .valueChanged
        )
        
        return cell
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        let index = sender.tag
        data[index].isOn = sender.isOn
        print("\(data[index].title) переключен на \(sender.isOn ? "ON" : "OFF")")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SheduleViewController: UICollectionViewDelegateFlowLayout {
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
}
