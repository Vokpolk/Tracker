import UIKit

final class StatisticCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    
    private var count: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(resource: .ypBlack)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        contentView.backgroundColor = UIColor(resource: .ypWhite)
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.clear.cgColor
        contentView.layer.cornerRadius = 16
        
        let colors: [UIColor] = [.red, .green, .blue]
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.cornerRadius = 16
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 1
        shapeLayer.fillRule = .evenOdd
        
        let outerPath = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
        let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), cornerRadius: 16)
        outerPath.append(innerPath)
        
        shapeLayer.path = outerPath.cgPath
        gradientLayer.mask = shapeLayer
        
        contentView.layer.addSublayer(gradientLayer)
        
        [
            count,
            titleLabel,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            count.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            count.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            count.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with title: String, number: Int) {
        titleLabel.text = title
        count.text = String(number)
    }
}
