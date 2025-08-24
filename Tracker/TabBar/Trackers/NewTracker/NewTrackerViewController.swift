import UIKit

final class NewTrackerViewController: UIViewController {
    // MARK: - Private Properties
    weak var delegate: TrackersDelegate?
    // MARK: - Private Properties
    static var trackerId: UInt = 0
    
    private let scrollView: UIScrollView = UIScrollView()
    private var trackerTitle: String? = nil
    private var trackerCategory: String? = nil
    private var trackerWeekShedule: [WeekShedule] = []
    private var trackerEmoji: String? = nil
    private var trackerColor: UIColor? = nil
    private var isCreateTrackerEnabled: Bool = false
    
    private let items = [
        "Категория",
        "Расписание"
    ]
    private let cellHeight = 75
    
    private let emojies = [
        "🍇", "🍈", "🍉", "🍊", "🍋", "🍌",
        "🍍", "🥭", "🍎", "🍏", "🍐", "🍒",
        "🍓", "🫐", "🥝", "🍅", "🫒", "🥥"
    ]
    private let colors = [
        UIColor(resource: .ypColor1), UIColor(resource: .ypColor2),
        UIColor(resource: .ypColor3), UIColor(resource: .ypColor4),
        UIColor(resource: .ypColor5), UIColor(resource: .ypColor6),
        UIColor(resource: .ypColor7), UIColor(resource: .ypColor8),
        UIColor(resource: .ypColor9), UIColor(resource: .ypColor10),
        UIColor(resource: .ypColor11), UIColor(resource: .ypColor12),
        UIColor(resource: .ypColor13), UIColor(resource: .ypColor14),
        UIColor(resource: .ypColor15), UIColor(resource: .ypColor16),
        UIColor(resource: .ypColor17), UIColor(resource: .ypColor18)
    ]
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.5
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            NewTrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: "categoryAndSheduleCell"
        )
        collectionView.layer.cornerRadius = 16
        collectionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        collectionView.clipsToBounds = true
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private lazy var emojiCollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(
            EmojiSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "emojiHeader"
        )
        collectionView.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: "emojiCell"
        )
        return collectionView
    }()
    
    private lazy var colorCollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        collectionView.register(
            ColorSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "colorHeader"
        )
        collectionView.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: "colorCell"
        )
        return collectionView
    }()
    
    private lazy var newHabitLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var enterTrackerName: UITextField = {
        let enterTrackerName = UITextField()
        enterTrackerName.placeholder = "Введите название трекера"
        enterTrackerName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: enterTrackerName.frame.height))
        enterTrackerName.leftViewMode = .always
        enterTrackerName.backgroundColor = UIColor(resource: .ypBackground)
        enterTrackerName.layer.cornerRadius = 16
        enterTrackerName.clearButtonMode = .whileEditing
        enterTrackerName.addTarget(
            self,
            action: #selector(Self.textFieldDidReturn),
            for: .editingDidEndOnExit
        )
        enterTrackerName.addTarget(
            self,
            action: #selector(Self.textFieldDidReturn),
            for: .editingDidEnd
        )
        return enterTrackerName
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypWhite)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(resource: .ypRed).cgColor
        button.setTitleColor(UIColor(resource: .ypRed), for: .normal)
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
        button.backgroundColor = UIColor(resource: .ypGray)
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
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let trackerStore: TrackerStore
    
    // MARK: - Initializers
    
    init(trackerStore: TrackerStore) {
        self.trackerStore = trackerStore
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
        hideKeyboardEvent()
        initUIObjects()
    }
    
    // MARK: - Private Methods
    private func setupScrollView() {
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
        view.backgroundColor = UIColor(resource: .ypWhite)
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(createButton)
        [
            newHabitLabel,
            enterTrackerName,
            collectionView,
            emojiCollectionView,
            colorCollectionView,
            stackView
        ].forEach {
            scrollView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            newHabitLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            newHabitLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 25),
            
            enterTrackerName.topAnchor.constraint(equalTo: newHabitLabel.bottomAnchor, constant: 38),
            enterTrackerName.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            enterTrackerName.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            enterTrackerName.heightAnchor.constraint(equalToConstant: 75),
            enterTrackerName.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: enterTrackerName.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant:  -16),
            collectionView.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: CGFloat(cellHeight * items.count) - 1),
            collectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            emojiCollectionView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 32),
            emojiCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 19),
            emojiCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant:  -19),
            emojiCollectionView.bottomAnchor.constraint(equalTo: emojiCollectionView.topAnchor, constant: CGFloat(220)),
            emojiCollectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            colorCollectionView.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorCollectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 19),
            colorCollectionView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant:  -19),
            colorCollectionView.bottomAnchor.constraint(equalTo: colorCollectionView.topAnchor, constant: CGFloat(220)),
            colorCollectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        [collectionView, emojiCollectionView, colorCollectionView].forEach {
            $0.dataSource = self
            $0.delegate = self
        }
    }
    
    @objc private func cancelButtonTap() {
        print("cancel button tap")
        trackerTitle = nil
        trackerCategory = nil
        trackerWeekShedule.removeAll()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTap() {
        print("create button tap")
        if isCreateTrackerEnabled {
            delegate?.createTracker(makeTracker())
            dismiss(animated: true, completion: nil)
        }
    }
    
    private func makeTracker() -> Tracker {
        let monday = trackerWeekShedule[0].isOn ? WeekDay.monday : nil
        let tuesday = trackerWeekShedule[1].isOn ? WeekDay.tuesday : nil
        let wednesday = trackerWeekShedule[2].isOn ? WeekDay.wednesday : nil
        let thursday = trackerWeekShedule[3].isOn ? WeekDay.thursday : nil
        let friday = trackerWeekShedule[4].isOn ? WeekDay.friday : nil
        let saturday = trackerWeekShedule[5].isOn ? WeekDay.saturday : nil
        let sunday = trackerWeekShedule[6].isOn ? WeekDay.sunday : nil
        let optionalWeekDays: [WeekDay?] = [
            monday,
            tuesday,
            wednesday,
            thursday,
            friday,
            saturday,
            sunday
        ]
        let weekDays = optionalWeekDays.compactMap{
            $0
        }
        NewTrackerViewController.trackerId = trackerStore.countFetch() + 1
        print("id нового трекера: \(NewTrackerViewController.trackerId)")
        return Tracker(
            id: NewTrackerViewController.trackerId,
            name: trackerTitle!,
            color: trackerColor!,
            emoji: trackerEmoji!,
            weekDays: weekDays
        )
    }
    
    @objc func textFieldDidReturn(_ textField: UITextField) {
        enterTrackerName.resignFirstResponder()
        handleEnterPressed(textField.text)
    }
    private func handleEnterPressed(_ trackerName: String?) {
        guard let trackerName else { return }
        print(trackerName)
        if !trackerName.isEmpty {
            trackerTitle = trackerName
        } else {
            trackerTitle = nil
        }
        checkFieldsToUpdateCreateButton()
    }
    
    private func hideKeyboardEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func checkFieldsToUpdateCreateButton() {
        var isSheduleEmpty = true
        for trackerDay in trackerWeekShedule {
            if trackerDay.isOn == true {
                isSheduleEmpty = false
                break
            }
        }
        if trackerCategory == nil ||
            trackerTitle == nil ||
            trackerEmoji == nil ||
            trackerColor == nil ||
            isSheduleEmpty
        {
            createButton.backgroundColor = UIColor(resource: .ypGray)
            isCreateTrackerEnabled = false
        } else {
            createButton.backgroundColor = UIColor(resource: .ypBlack)
            isCreateTrackerEnabled = true
        }
    }
}
// MARK: - UICollectionViewDataSource
extension NewTrackerViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == self.collectionView {
            return items.count
        } else if collectionView == emojiCollectionView {
            return emojies.count
        } else {
            return colors.count
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "categoryAndSheduleCell",
                for: indexPath
            ) as! NewTrackerCollectionViewCell
            
            switch indexPath.row {
            case 0:
                cell.configure(title: items[indexPath.row], subtitle: trackerCategory)
            case 1:
                if !trackerWeekShedule.isEmpty {
                    cell.configure(title: items[indexPath.row], subtitle: configSheduleCell())
                } else {
                    cell.configure(title: items[indexPath.row], subtitle: nil)
                }
                checkFieldsToUpdateCreateButton()
            default:
                print("swift требует эту ..")
            }
            
            return cell
        } else if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "emojiCell",
                for: indexPath
            ) as! EmojiCollectionViewCell
            cell.configure(title: emojies[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "colorCell",
                for: indexPath
            ) as! ColorCollectionViewCell
            cell.configure(color: colors[indexPath.row])
            return cell
        }
    }
    
    func configSheduleCell() -> String {
        var days = trackerWeekShedule.compactMap {
            $0.isOn ? $0.title : nil
        }
        
        var allDays = 0
        for (index, day) in days.enumerated() {
            if day == "Понедельник" {
                days[index] = "Пн"
            } else if day == "Вторник" {
                days[index] = "Вт"
            } else if day == "Среда" {
                days[index] = "Ср"
            } else if day == "Четверг" {
                days[index] = "Чт"
            } else if day == "Пятница" {
                days[index] = "Пт"
            } else if day == "Суббота" {
                days[index] = "Сб"
            } else if day == "Воскресенье" {
                days[index] = "Вс"
            }
            allDays += 1
        }
        if allDays == trackerWeekShedule.count {
            return "Каждый день"
        }
        
        let result = days.map { $0 }.joined(separator: ", ")
        return result
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        if collectionView == emojiCollectionView {
            var id: String
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                id = "emojiHeader"
            case UICollectionView.elementKindSectionFooter:
                id = "footer"
            default:
                id = ""
            }
            
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: id,
                for: indexPath
            ) as! EmojiSupplementaryView
            view.titleLabel.text = "Emoji"
            return view
        } else if collectionView == colorCollectionView {
            var id: String
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                id = "colorHeader"
            case UICollectionView.elementKindSectionFooter:
                id = "footer"
            default:
                id = ""
            }
            
            let view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: id,
                for: indexPath
            ) as! ColorSupplementaryView
            view.titleLabel.text = "Цвет"
            return view
        }
        else {
            return UICollectionReusableView()
        }
    }
}
// MARK: - SheduleDelegate
extension NewTrackerViewController: SheduleDelegate {
    func getWeekDays(_ week: [WeekShedule]) {
        for day in week {
            trackerWeekShedule.append(day)
        }
        for day in trackerWeekShedule {
            print("\(day.title): \(day.isOn)")
        }
        collectionView.reloadData()
    }
}
// MARK: - UICollectionViewDelegateFlowLayout
extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: collectionView.bounds.width, height: 75)
        } else {
            return CGSize(
                width: collectionView.bounds.width / 6 - 5,
                height: collectionView.bounds.width / 6 - 5
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        if collectionView == self.collectionView {
            return 0
        } else {
            return 5
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if collectionView == self.collectionView {
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        else {
            UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: 0, height: 0)
        } else {
            return CGSize(
                width: collectionView.frame.width,
                height: 25
            )
        }
    }
    
    // MARK: - Выделение ячейки
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == self.collectionView {
            switch indexPath.row {
            case 0:
                print("Заглушка категории")
                let cell = collectionView.cellForItem(at: indexPath) as? NewTrackerCollectionViewCell
                trackerCategory = TrackerCategories.important
                cell?.configure(title: items[indexPath.row], subtitle: trackerCategory)
                checkFieldsToUpdateCreateButton()
            case 1:
                trackerWeekShedule.removeAll(keepingCapacity: true)
                let sheduleVC = SheduleViewController(delegate: self)
                present(sheduleVC, animated: true)
            default:
                break
            }
        } else if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            guard let cell else { return }
            
            cell.isCellPressed(true)
            trackerEmoji = cell.getTitleLabel()
            checkFieldsToUpdateCreateButton()
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            guard let cell else { return }
            
            cell.isCellPressed(true)
            trackerColor = cell.getColor()
            checkFieldsToUpdateCreateButton()
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        if collectionView == emojiCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell
            guard let cell else { return }
            
            cell.isCellPressed(false)
        } else if collectionView == colorCollectionView {
            let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell
            guard let cell else { return }
            
            cell.isCellPressed(false)
        }
    }
}
