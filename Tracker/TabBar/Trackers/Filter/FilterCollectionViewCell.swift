import UIKit

protocol FilterDelegate: AnyObject {
    func newFilter(_ name: String)
}

final class FilterCollectionViewCell: UICollectionViewCell {
    // MARK: - Private Properties
    private var isPicked: Bool = false
    
    // MARK: - UI Elements
    private(set) var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .ypGray)
        return view
    }()
    
    private lazy var cellPickedImageView: UIImageView = {
        let checkMarkImage = UIImage(resource: .checkMark)
        let imageView = UIImageView(image: checkMarkImage)
        imageView.isHidden = true
        return imageView
    }()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
        setupConstraints()
    }
    
    // MARK: - Setup
    private func setupViews() {
        [
            titleLabel,
            cellPickedImageView,
            separatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        contentView.backgroundColor = UIColor(resource: .ypBackground)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellPickedImageView.leadingAnchor, constant: -16),
            
            cellPickedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellPickedImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -16),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    // MARK: - Configuration
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    func pickFilter(_ picked: Bool, title: String) {
        if title == NSLocalizedString("trackers for today", comment: "") ||
            title == NSLocalizedString("all trackers", comment: "") {
            cellPickedImageView.isHidden = true
            return
        }
        isPicked = picked
        picked ? (cellPickedImageView.isHidden = false) : (cellPickedImageView.isHidden = true)
    }
}
