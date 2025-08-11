import UIKit

final class NewTrackerCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillEqually
        stack.spacing = 8 // Расстояние между кнопками
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let arrowImageView: UIImageView = {
        let arrowImage = UIImage(systemName: "chevron.right")?
            .withRenderingMode(.alwaysTemplate)
        
        let imageView = UIImageView(image: arrowImage)
        imageView.tintColor = .ypGray
        
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        [
            stackView,
            separatorView,
            arrowImageView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        contentView.backgroundColor = .ypBackground
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -16),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            arrowImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            arrowImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 13),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, subtitle: String?) {
        titleLabel.text = title
        
        if let subtitle = subtitle, !subtitle.isEmpty {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
            stackView.spacing = 4
        } else {
            subtitleLabel.text = nil
            subtitleLabel.isHidden = true
            stackView.spacing = 0
        }
    }
}
