import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private lazy var backgroundEmojiView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .ypWhite)
        view.layer.cornerRadius = 16
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private var isPressed: Bool = false
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        [
            backgroundEmojiView,
            titleLabel,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            backgroundEmojiView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundEmojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundEmojiView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundEmojiView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(title: String) {
        titleLabel.text = title
    }
    
    func isCellPressed(_ pressed: Bool) {
        isPressed = pressed
        if pressed {
            backgroundEmojiView.backgroundColor = UIColor(resource: .ypLightGray)
        } else {
            backgroundEmojiView.backgroundColor = UIColor(resource: .ypWhite)
        }
    }
    
    func getTitleLabel() -> String? {
        if isPressed {
            return titleLabel.text
        } else {
            return nil
        }
    }
}

