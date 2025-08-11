import UIKit

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UInt, at indexPAth: IndexPath)
    func uncompleteTracker(id: UInt, at indexPAth: IndexPath)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    var weekDays: [WeekDay] = []
    
    // MARK: - Private Properties
    private var color = UIColor()
    private let cardBackground = UIView()
    private let emojiBackground = UIView()
    private let emojiLabel = UILabel()
    private let trackerName = UILabel()
    private let daysCount = UILabel()
    private let button = UIButton(type: .custom)
    
    private var isCompletedToday: Bool = false
    private var trackerId: UInt?
    private var indexPath: IndexPath?
    
    // MARK: - LifeCycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        [
            cardBackground,
            emojiBackground,
            emojiLabel,
            trackerName,
            daysCount,
            button
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        initConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) error")
    }
    
    // MARK: - Public Methods
    func configure(
        id: UInt,
        color: UIColor,
        emoji: String,
        tracker: String,
        completedDays: Int,
        weekDays: [WeekDay],
        isCompletedToday: Bool,
        indexPath: IndexPath
    ) {
        // номер трекера
        trackerId = id
        
        // цвет
        self.color = color
        
        // карточка
        cardBackground.backgroundColor = color
        cardBackground.layer.cornerRadius = 16
        
        // смайлик
        emojiLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emojiLabel.text = emoji
        
        // фон смайлика
        emojiBackground.backgroundColor = UIColor(named: "YPEmojiBackground")
        emojiBackground.layer.cornerRadius = 12
        
        // имя трекера
        trackerName.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        trackerName.numberOfLines = 0
        trackerName.textAlignment = .left
        trackerName.contentMode = .bottom
        trackerName.text = tracker
        trackerName.textColor = .white
        
        // количество дней
        daysCount.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        daysCount.textAlignment = .left
        let wordDay = pluralizeDays(completedDays)
        daysCount.text = wordDay
        daysCount.textColor = .black
        
        // дни недели
        self.weekDays = weekDays
        
        // завершен ли трекер сегодня
        self.isCompletedToday = isCompletedToday
        
        // кнопка
        button.addTarget(
            self,
            action: #selector(Self.buttonTap),
            for: .touchUpInside
        )
        let image = isCompletedToday ? UIImage(named: "Done") : UIImage(named: "Plus")
        let coloredImage = image?.withTintColor(color)
        button.setImage(coloredImage, for: .normal)
        
        // номер ячейки в коллекции
        self.indexPath = indexPath
    }
    
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - Private Methods
    private func initConstraints() {
        NSLayoutConstraint.activate([
            cardBackground.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardBackground.heightAnchor.constraint(equalToConstant: 90),
            
            emojiBackground.widthAnchor.constraint(equalToConstant: 24),
            emojiBackground.heightAnchor.constraint(equalToConstant: 24),
            emojiBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            emojiBackground.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackground.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackground.centerYAnchor),
            
            trackerName.topAnchor.constraint(equalTo: cardBackground.topAnchor, constant: 44),
            trackerName.leadingAnchor.constraint(equalTo: cardBackground.leadingAnchor, constant: 12),
            trackerName.trailingAnchor.constraint(equalTo: cardBackground.trailingAnchor, constant: -12),
            trackerName.heightAnchor.constraint(equalToConstant: 34),
            
            button.topAnchor.constraint(equalTo: cardBackground.bottomAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            button.widthAnchor.constraint(equalToConstant: 34),
            button.heightAnchor.constraint(equalToConstant: 34),
            
            daysCount.topAnchor.constraint(equalTo: cardBackground.bottomAnchor, constant: 16),
            daysCount.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysCount.trailingAnchor.constraint(equalTo: button.leadingAnchor, constant: -8),
            daysCount.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    @objc private func buttonTap() {
        changeButtonLabel()
        print("button tapped")
    }
    
    private func changeButtonLabel() {
        guard let trackerId, let indexPath else {
            assertionFailure("no tracker id")
            return
        }
        if isCompletedToday {
            delegate?.uncompleteTracker(id: trackerId, at: indexPath)
        } else {
            delegate?.completeTracker(id: trackerId, at: indexPath)
        }
    }
    
    private func pluralizeDays(_ day: Int) -> String {
        let absDay = abs(day)
        let lastTwo = absDay % 100
        let lastOne = absDay % 10
        
        if lastTwo >= 11 && lastTwo <= 19 {
            return "\(day) дней"
        } else {
            switch lastOne {
            case 1:
                return "\(day) день"
            case 2, 3, 4:
                return "\(day) дня"
            default:
                return "\(day) дней"
            }
        }
    }
}
