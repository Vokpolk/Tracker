import UIKit

final class NewTrackerViewController: UIViewController {
    
    // MARK: - Private Properties
    private let items = [
        "Категория",
        "Расписание"
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
            NewTrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        collectionView.layer.cornerRadius = 16
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collectionView.clipsToBounds = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var newHabitLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var enterTrackerName: UITextField = {
        let enterTrackerName = UITextField()
        enterTrackerName.placeholder = "Введите название трекера"
        enterTrackerName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: enterTrackerName.frame.height))
        enterTrackerName.leftViewMode = .always
        enterTrackerName.backgroundColor = .ypBackground
        enterTrackerName.layer.cornerRadius = 16
        enterTrackerName.clearButtonMode = .whileEditing
        enterTrackerName.addTarget(
            self,
            action: #selector(Self.textFieldDidReturn),
            for: .editingDidEndOnExit
        )
        return enterTrackerName
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypWhite
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(Self.cancelButtonTap),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .ypGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(Self.createButtonTap),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fillEqually
        stack.spacing = 8 // Расстояние между кнопками
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardEvent()
        initUIObjects()
    }
    
    // MARK: - Private Properties
    private func initUIObjects() {
        view.backgroundColor = .ypWhite
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        [
            newHabitLabel,
            enterTrackerName,
            collectionView,
            stackView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            newHabitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newHabitLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            
            enterTrackerName.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 38),
            enterTrackerName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            enterTrackerName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            enterTrackerName.heightAnchor.constraint(equalToConstant: 75),
            
            collectionView.topAnchor.constraint(equalTo: enterTrackerName.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -16),
            collectionView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: CGFloat(cellHeight * items.count) - 1),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // Фиксированная высота кнопок
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    @objc private func cancelButtonTap() {
        print("cancel button tap")
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTap() {
        print("create button tap")
    }
    
    @objc func textFieldDidReturn(_ textField: UITextField) {
        enterTrackerName.resignFirstResponder()
        handleEnterPressed(textField.text)
    }
    private func handleEnterPressed(_ trackerName: String?) {
        guard let trackerName else { return }
        print(trackerName)
    }
    
    private func hideKeyboardEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}

extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! NewTrackerCollectionViewCell
        
        cell.titleLabel.text = items[indexPath.row]
        return cell
    }
}

extension NewTrackerViewController: SheduleDelegate {
    func getWeekDays(_ week: [SwitchItem]) {
        for day in week {
            print(day.isOn)
        }
    }
}

extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        switch indexPath.row {
        case 0:
            print("Заглушка категории")
        case 1:
            let sheduleVC = SheduleViewController(delegate: self)
            present(sheduleVC, animated: true)
        default:
            break
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 75)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
}
