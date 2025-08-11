import UIKit

struct WeekShedule {
    let title: String
    var isOn: Bool
}

final class SheduleViewController: UIViewController {
    
    // MARK: - Private Properties
    private var data: [WeekShedule] = [
        WeekShedule(title: "Понедельник", isOn: false),
        WeekShedule(title: "Вторник", isOn: false),
        WeekShedule(title: "Среда", isOn: false),
        WeekShedule(title: "Четверг", isOn: false),
        WeekShedule(title: "Пятница", isOn: false),
        WeekShedule(title: "Суббота", isOn: false),
        WeekShedule(title: "Воскресенье", isOn: false)
    ]
    private let cellHeight = 75
    
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
        label.text = "Расписание"
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
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
        
        initUIObjects()
    }
    
    // MARK: - Private Properties
    private func initUIObjects() {
        view.backgroundColor = .ypWhite
        [
            sheduleLabel,
            collectionView,
            readyButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            sheduleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sheduleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            collectionView.topAnchor.constraint(equalTo: sheduleLabel.bottomAnchor, constant: 30),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
            collectionView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: CGFloat(cellHeight * data.count) - 1),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            // Фиксированная высота кнопок
            readyButton.heightAnchor.constraint(equalToConstant: 60),
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SwitchCell", for: indexPath) as! SheduleCollectionViewCell
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
