import UIKit

final class TrackersViewController: UIViewController {

    // MARK: - Public Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )
        return collectionView
    }()
    
    
    // MARK: - Private Properties
    private lazy var addTrackerButton: UIButton = {
        let trackerButton = UIButton.systemButton(
            with: UIImage(named: "Add tracker")!,
            target: nil,
            action: nil
        )
        trackerButton.addTarget(
            self,
            action: #selector(Self.didAddTrackerButtonTap),
            for: .touchUpInside
        )
        trackerButton.tintColor = UIColor(named: "YPBlack")
        return trackerButton
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ru_Ru")
        picker.calendar.firstWeekday = 2
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.clipsToBounds = true
        picker.layer.cornerRadius = 8
        picker.tintColor = .ypBlue
        picker.addTarget(
            self,
            action: #selector(Self.didDateButtonTap),
            for: .valueChanged
        )
        return picker
    }()
    
//    private lazy var dateButton: UIButton = {
//        let dateButton = UIButton(type: .system)
//        dateButton.setTitle("11.12.24", for: .normal)
//        dateButton.setTitleColor(UIColor(named: "YPBlack"), for: .normal)
//        dateButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
//        
//        dateButton.backgroundColor = UIColor(named: "YPGrayButton")
//        dateButton.layer.cornerRadius = 8
//        
//        dateButton.addTarget(
//            self,
//            action: #selector(Self.didDateButtonTap),
//            for: .touchUpInside
//        )
//        return dateButton
//    }()
    
    private var trackerLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = UIColor(named: "YPBlack")
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
        let starImage = UIImage(named: "Dizzy")
        let placeholderImageView = UIImageView(image: starImage)
        return placeholderImageView
    }()
    
    private lazy var questionLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = UIColor(named: "YPBlack")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardEvent()
        initUIObjects()
    }

    // MARK: - Private Methods
    @objc private func didAddTrackerButtonTap() {
        let newTrackerViewController = NewTrackerViewController()
        present(newTrackerViewController, animated: true)
    }
    
    @objc private func didDateButtonTap(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    private func initUIObjects() {
        view.backgroundColor = .ypWhite
        [
            addTrackerButton,
//            dateButton,
            datePicker,
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
            datePicker.widthAnchor.constraint(equalToConstant: 98),
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            
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
    
    private func hideKeyboardEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard() {
        searchBar.searchTextField.endEditing(true)
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.isHidden = categories.isEmpty
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        ) as? TrackerCollectionViewCell
        
        cell?.initProperties(
            color: .ypGreen,
            emoji: "🥹",
            tracker: "Учиться",
            days: 0
        )
        return cell!
    }
}

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
}
