import UIKit

final class SheduleCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
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
    
    let cellSwitch: UISwitch = {
        let sw = UISwitch()
        sw.onTintColor = .systemBlue  // Цвет включенного состояния
        sw.translatesAutoresizingMaskIntoConstraints = false
        return sw
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
            cellSwitch,
            separatorView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        contentView.backgroundColor = UIColor(resource: .ypBackground)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cellSwitch.leadingAnchor, constant: -16),
            
            // Switch constraints
            cellSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cellSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            // Separator constraints
            separatorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant:  -16),
            separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    // MARK: - Configuration
    func configure(with title: String, isOn: Bool) {
        titleLabel.text = title
        cellSwitch.isOn = isOn
    }
}
