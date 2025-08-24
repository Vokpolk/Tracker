import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private Properties
    private var currentDay: Date = Date()
    private var defaultCategory: TrackerCategory = TrackerCategory(
        title: TrackerCategories.important,
        trackers: []
    )
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            TrackersSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        return collectionView
    }()
    
    private lazy var addTrackerButton: UIButton = {
        let trackerButton = UIButton.systemButton(
            with: UIImage(resource: .addTracker),
            target: nil,
            action: nil
        )
        trackerButton.addTarget(
            self,
            action: #selector(Self.didAddTrackerButtonTap),
            for: .touchUpInside
        )
        trackerButton.tintColor = UIColor(resource: .ypBlack)
        return trackerButton
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_Ru")
        picker.calendar.firstWeekday = 2
        picker.tintColor = UIColor(resource: .ypBlue)
        picker.backgroundColor = .clear
        picker.subviews.forEach { $0.backgroundColor = .clear }
        picker.subviews.forEach { $0.tintColor = .clear }
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.clipsToBounds = true
        picker.layer.cornerRadius = 8
        picker.isUserInteractionEnabled = true

        picker.addTarget(
            self,
            action: #selector(Self.dateChanged),
            for: .valueChanged
        )
        return picker
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        currentDay = datePicker.date
        label.textAlignment = .center
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.backgroundColor = UIColor(resource: .ypGrayButton)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.layer.cornerRadius = 10
        return searchBar
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let starImage = UIImage(resource: .dizzy)
        let placeholderImageView = UIImageView(image: starImage)
        return placeholderImageView
    }()
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private let trackerStore: TrackerStore
    private let trackerRecordStore: TrackerRecordStore
    private let trackerCategoryStore: TrackerCategoryStore
    
    // MARK: - Initializers
    
    init(trackerStore: TrackerStore,
         trackerRecordStore: TrackerRecordStore,
         trackerCategoryStore: TrackerCategoryStore
    ) {
        self.trackerStore = trackerStore
        self.trackerRecordStore = trackerRecordStore
        self.trackerCategoryStore = trackerCategoryStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardEvent()
        initUIObjects()
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        
        completedTrackers = trackerRecordStore.trackerRecords
        categories.append(
            TrackerCategory(
                title: TrackerCategories.important,
                trackers: trackerStore.trackers
            )
        )
        dateChanged()
        collectionView.reloadData()
    }

    // MARK: - Private Methods
    @objc private func didAddTrackerButtonTap() {
        let newTrackerViewController = NewTrackerViewController(trackerStore: trackerStore)
        newTrackerViewController.delegate = self
        present(newTrackerViewController, animated: true)
    }
    
    @objc private func dateChanged() {
        currentDay = datePicker.date
        updateDateText()
        let calendar = Calendar.current
        let filterWeakDay = calendar.component(.weekday, from: currentDay)
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                tracker.weekDays.contains { weekDay in
                    weekDay.rawValue == filterWeakDay
                }
            }
            if trackers.isEmpty {
                return nil
            }
            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
        
        collectionView.reloadData()
    }
    
    private func initUIObjects() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        updateDateText()
        [
            addTrackerButton,
            datePicker,
            dateLabel,
            trackerLabel,
            searchBar,
            placeholderImageView,
            questionLabel,
            collectionView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            addTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 6),
            addTrackerButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            
            datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            datePicker.widthAnchor.constraint(equalToConstant: 77),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            dateLabel.widthAnchor.constraint(equalToConstant: 77),
            dateLabel.heightAnchor.constraint(equalToConstant: 34),
            
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            trackerLabel.widthAnchor.constraint(equalToConstant: 254),
            trackerLabel.heightAnchor.constraint(equalToConstant: 41),
            
            searchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.searchTextField.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 0),
            searchBar.searchTextField.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: 0),
            searchBar.searchTextField.topAnchor.constraint(equalTo: searchBar.topAnchor, constant: 0),
            searchBar.searchTextField.bottomAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            
            placeholderImageView.topAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            questionLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            questionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func updateDateText() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateLabel.text = dateFormatter.string(from: currentDay)
    }
    
    private func hideKeyboardEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard() {
        searchBar.searchTextField.endEditing(true)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            return 0
        }
        collectionView.isHidden = false
        return visibleCategories[0].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[0].trackers[indexPath.row]
        cell.delegate = self
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.id == tracker.id}.count
        cell.configure(
            id: tracker.id,
            color: tracker.color,
            emoji: tracker.emoji,
            tracker: tracker.name,
            completedDays: completedDays,
            weekDays: tracker.weekDays,
            isCompletedToday: isCompletedToday,
            indexPath: indexPath
        )
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        case UICollectionView.elementKindSectionFooter:
            id = "footer"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: id,
            for: indexPath
        ) as! TrackersSupplementaryView
        view.titleLabel.text = TrackerCategories.important
        return view
    }
    
    private func isTrackerCompletedToday(id: UInt) -> Bool {
        completedTrackers.contains { trackerRecord in
            isSameTrackerRecord(trackerRecord, id: id)
        }
    }
    
    private func isSameTrackerRecord(_ trackerRecord: TrackerRecord, id: UInt) -> Bool {
        let isSameDay = Calendar.current.isDate(
            trackerRecord.date,
            inSameDayAs: currentDay
        )
        return trackerRecord.id == id && isSameDay
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(id: UInt, at indexPath: IndexPath) {
        if isDateInFuture(currentDay) {
            return
        }
        
        let trackerRecord = TrackerRecord(id: id, date: currentDay)
        completedTrackers.append(trackerRecord)
        trackerRecordStore.addNewTrackerRecord(trackerRecord)
        
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    func uncompleteTracker(id: UInt, at indexPath: IndexPath) {
        for trackerRecord in completedTrackers {
            if isSameTrackerRecord(trackerRecord, id: id) {
                trackerRecordStore.removeTrackerRecord(id, with: trackerRecord.date)
            }
        }
        completedTrackers.removeAll { trackerRecord in
            isSameTrackerRecord(trackerRecord, id: id)
        }
        
        UIView.performWithoutAnimation {
            collectionView.reloadItems(at: [indexPath])
        }
    }
    
    private func isDateInFuture(_ selectedDate: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: selectedDate)
        return selectedDate > today
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width / 2 - 21, height: 148)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        10
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        return CGSize(
            width: collectionView.frame.width,
            height: 22
        )
    }
}

// MARK: - TrackersDelegate
extension TrackersViewController: TrackersDelegate {
    func createTracker(_ tracker: Tracker) {
        categories[0].trackers.append(tracker)
        dateChanged()
        do {
            try trackerStore.addNewTracker(tracker)
        } catch {
            fatalError("Не получилось создать Tracker в БД")
        }
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func store(_ store: TrackerStore) {
        collectionView.reloadData()
    }
}

// MARK: - TrackerRecordStoreDelegate
extension TrackersViewController: TrackerRecordStoreDelegate {
    func store(_ store: TrackerRecordStore) {
        collectionView.reloadData()
    }
}
