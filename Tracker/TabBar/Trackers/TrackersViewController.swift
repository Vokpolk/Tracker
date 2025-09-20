import UIKit
import AppMetricaCore

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
    
    private var searchText: String?
    
    private var pickedFilter: String = PickedFilter.allTrackers
    
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
        collectionView.backgroundColor = UIColor(resource: .ypWhite)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
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
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.backgroundColor = UIColor(resource: .ypGrayButton)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        label.layer.cornerRadius = 8
        return label
    }()
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackers", comment: "")//"Трекеры"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("search", comment: "")//"Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchTextField.layer.cornerRadius = 10
        searchBar.searchTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        return searchBar
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let starImage = UIImage(resource: .dizzy)
        let placeholderImageView = UIImageView(image: starImage)
        return placeholderImageView
    }()
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("what are we going to track?", comment: "")//"Что будем отслеживать?"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var nothingFoundImageView: UIImageView = {
        let emojiImage = UIImage(resource: .glasses)
        let placeholderImageView = UIImageView(image: emojiImage)
        return placeholderImageView
    }()
    
    private lazy var nothingFoundLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("nothing was found", comment: "")//"Ничего не найдено"
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("filters", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .white
        button.backgroundColor = UIColor(resource: .ypBlue)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(Self.filterButtonTap),
            for: .touchUpInside
        )
        return button
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
        UserDefaults.standard.set(PickedFilter.allTrackers, forKey: PickedFilter.filter)
        UserDefaults.standard.set(trackerStore.trackers.count, forKey: "trackers count")
        hideKeyboardEvent()
        initUIObjects()
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        
        
        completedTrackers = trackerRecordStore.trackerRecords
        categories = trackerCategoryStore.trackerCategories
        
        dateChanged()
        collectionView.reloadData()
    }

    // MARK: - Private Methods
    
    @objc private func didAddTrackerButtonTap() {
        let newTrackerViewController = NewTrackerViewController(trackerStore: trackerStore)
        newTrackerViewController.delegate = self
        newTrackerViewController.configureHabit()
//        report(event: )
        AppMetricaManager.shared.reportAddTrack(screen: "Main")
        present(newTrackerViewController, animated: true)
    }
    
    @objc private func dateChanged() {
        if pickedFilter == PickedFilter.trackersForToday {
            pickedFilter = PickedFilter.allTrackers
        }
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
        
        newFilter(NSLocalizedString(pickedFilter, comment: ""))
        
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            filterButton.isHidden = true
        } else {
            filterButton.isHidden = false
        }
        
        if let searchText {
            filterTrackersBySearchField(searchText)
        }
        
        collectionView.reloadData()
    }
    
    @objc private func filterButtonTap() {
        let filterVC = FilterViewController()
        if let filterName = UserDefaults.standard.string(forKey: PickedFilter.filter) {
            filterVC.initFilter(filterName)
            filterVC.delegate = self
            AppMetricaManager.shared.reportFilter(screen: "Main")
            present(filterVC, animated: true)
        }
    }
    
    private func initUIObjects() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        
        nothingFoundImageView.isHidden = true
        nothingFoundLabel.isHidden = true
        updateDateText()
        [
            addTrackerButton,
            datePicker,
            dateLabel,
            trackerLabel,
            searchBar,
            placeholderImageView,
            questionLabel,
            collectionView,
            nothingFoundImageView,
            nothingFoundLabel,
            filterButton,
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
            
            nothingFoundImageView.topAnchor.constraint(equalTo: view.centerYAnchor),
            nothingFoundImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nothingFoundLabel.topAnchor.constraint(equalTo: nothingFoundImageView.bottomAnchor, constant: 8),
            nothingFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func updateDateText() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        dateLabel.text = dateFormatter.string(from: currentDay)
    }
    
    @objc private func textDidChange(_ searchField: UISearchTextField) {
        if let searchText = searchField.text, !searchText.isEmpty {
            self.searchText = searchText
            filterTrackersBySearchField(searchText)
            placeholderImageView.isHidden = true
            questionLabel.isHidden = true
        } else {
            searchText = nil
            nothingFoundImageView.isHidden = true
            nothingFoundLabel.isHidden = true
            placeholderImageView.isHidden = false
            questionLabel.isHidden = false
            dateChanged()
        }
    }
    
    private func filterTrackersBySearchField(_ searchText: String) {
        if !searchText.isEmpty {
            let calendar = Calendar.current
            let filterWeakDay = calendar.component(.weekday, from: currentDay)
            visibleCategories = categories.compactMap { category in
                var trackers = category.trackers.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                trackers = trackers.filter { tracker in
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
            if visibleCategories.isEmpty {
                nothingFoundImageView.isHidden = false
                nothingFoundLabel.isHidden = false
                filterButton.isHidden = true
            } else {
                nothingFoundImageView.isHidden = true
                nothingFoundLabel.isHidden = true
                filterButton.isHidden = false
            }
            collectionView.reloadData()
        }
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if visibleCategories.isEmpty {
            collectionView.isHidden = true
            return 0
        }
        collectionView.isHidden = false
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
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
        ) as? TrackersSupplementaryView
        guard let view else {
            return UICollectionReusableView()
        }
        view.titleLabel.text = visibleCategories[indexPath.section].title// TrackerCategories.important
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
        
        UserDefaults.standard.set(trackerRecordStore.trackerRecords.count, forKey: "completed trackers")
        
        
        AppMetricaManager.shared.reportTrack(screen: "Main")
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
        
        UserDefaults.standard.set(trackerRecordStore.trackerRecords.count, forKey: "completed trackers")
    }
    
    private func isDateInFuture(_ selectedDate: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDate = calendar.startOfDay(for: selectedDate)
        return selectedDate > today
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else {
            return nil
        }
        
        guard
            let indexPath = indexPaths.first,
            let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell
        else {
            return nil
        }
        
        
        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            actionProvider: { actions in
            return UIMenu(children: [
                UIAction(
                    title: NSLocalizedString("edit", comment: "")
                ) { [weak self] _ in
                    guard let self else { return }
                    let vc = NewTrackerViewController(trackerStore: trackerStore)
                    vc.delegate = self
                    vc.configureHabit(
                        cell.getTracker(),
                        completedTrackers.filter { $0.id == cell.getTracker().id}.count,
                        visibleCategories[indexPath.section].title
                    )
                    
                    AppMetricaManager.shared.reportEdit(screen: "Main")
                    present(vc, animated: true)
                },
                UIAction(
                    title: NSLocalizedString("delete", comment: ""),
                    attributes: .destructive
                ) { [weak self] _ in
                    guard let self else { return }
                    trackerStore.deleteTracker(with: Int32(cell.getTracker().id))
                    categories = trackerCategoryStore.trackerCategories
                    completedTrackers = trackerRecordStore.trackerRecords
                    
                    UserDefaults.standard.set(trackerStore.trackers.count, forKey: "trackers count")
                    UserDefaults.standard.set(completedTrackers.count, forKey: "completed trackers")
                    dateChanged()
                    AppMetricaManager.shared.reportDelete(screen: "Main")
                },
            ])
        })
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration
    ) -> UITargetedPreview? {
        
        guard let indexPath = configuration.identifier as? NSIndexPath,
              let cell = collectionView.cellForItem(at: indexPath as IndexPath) as? TrackerCollectionViewCell else {
            return nil
        }
        
        
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: cell.emojiLabel.bounds, cornerRadius: 22) // Только imageView
        parameters.backgroundColor = .ypBlack
        
        
        return UITargetedPreview(view: cell.emojiLabel, parameters: parameters)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else {
            return nil
        }
        
        let imageView = cell.cardBackground
        imageView.addSubview(cell.emojiBackground)
        imageView.addSubview(cell.emojiLabel)
        imageView.addSubview(cell.trackerName)
        
        let parameters = UIPreviewParameters()
        parameters.visiblePath = UIBezierPath(roundedRect: imageView.bounds, cornerRadius: 16)
        parameters.backgroundColor = .clear
        
        let preview = UITargetedPreview(view: imageView, parameters: parameters)
        
        return preview
    }
}

// MARK: - TrackersDelegate
extension TrackersViewController: TrackersDelegate {
    func createTracker(_ tracker: Tracker, with category: String, isNew: Bool) {
        categories = trackerCategoryStore.trackerCategories
        
        var count = 0
        if !isNew {
            categories.forEach { trackerCategory in
                if let index = trackerCategory.trackers.firstIndex(where: { oldTracker in
                    oldTracker.id == tracker.id
                }) {
                    categories[count].trackers.remove(at: index)
                }
                count += 1
            }
        }
        
        if let index = categories.firstIndex(where: { $0.title == category }) {
            categories[index].trackers.append(tracker)
        }
        
        dateChanged()
        do {
            if isNew {
                try trackerStore.addNewTracker(tracker, to: category)
            } else {
                try trackerStore.updateTracker(tracker, to: category)
            }
        } catch {
            assertionFailure("Не получилось создать Tracker в БД")
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

// MARK: - FilterDelegate
extension TrackersViewController: FilterDelegate {
    func newFilter(_ name: String) {
        if name == NSLocalizedString("all trackers", comment: "") {
            UserDefaults.standard.set(PickedFilter.allTrackers, forKey: PickedFilter.filter)
            pickedFilter = PickedFilter.allTrackers
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
        } else if name == NSLocalizedString("trackers for today", comment: "") {
            UserDefaults.standard.set(PickedFilter.trackersForToday, forKey: PickedFilter.filter)
            pickedFilter = PickedFilter.trackersForToday
            datePicker.date = Date()
            datePicker.setDate(Date(), animated: false)
            currentDay = Date()
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
        } else if name == NSLocalizedString("completed", comment: "") {
            UserDefaults.standard.set(PickedFilter.completedTrackers, forKey: PickedFilter.filter)
            
            pickedFilter = PickedFilter.completedTrackers
            let calendar = Calendar.current
            let filterWeekDay = calendar.component(.weekday, from: currentDay)
            visibleCategories = categories.compactMap { category in
                var trackers = category.trackers.filter { tracker in
                    isTrackerCompletedToday(id: tracker.id)
                }
                trackers = trackers.filter { tracker in
                    tracker.weekDays.contains { WeekDay in
                        WeekDay.rawValue == filterWeekDay
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
            print(currentDay)
        } else if name == NSLocalizedString(PickedFilter.notCompletedTrackers, comment: "") {
            UserDefaults.standard.set("not completed", forKey: PickedFilter.filter)
            
            pickedFilter = PickedFilter.notCompletedTrackers
            let calendar = Calendar.current
            let filterWeekDay = calendar.component(.weekday, from: currentDay)
            visibleCategories = categories.compactMap { category in
                var trackers = category.trackers.filter { tracker in
                    !isTrackerCompletedToday(id: tracker.id)
                }
                trackers = trackers.filter { tracker in
                    tracker.weekDays.contains { WeekDay in
                        WeekDay.rawValue == filterWeekDay
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
            print(currentDay)
        }
        updateDateText()
        collectionView.reloadData()
    }

}
