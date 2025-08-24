import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    // MARK: - UI Elements
    private lazy var borderColorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .ypWhite)
        view.layer.borderColor = UIColor(resource: .ypWhite).cgColor
        view.layer.borderWidth = 3
        view.layer.cornerRadius = 8
        return view
    }()
    private lazy var colorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(resource: .ypWhite)
        view.layer.cornerRadius = 8
        return view
    }()
    
    private var isPressed: Bool = false
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        [
            borderColorView,
            colorView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            borderColorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            borderColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            borderColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            borderColorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(color: UIColor) {
        colorView.backgroundColor = color
    }
    
    func isCellPressed(_ pressed: Bool) {
        isPressed = pressed
        if pressed {
            borderColorView.layer.borderColor = colorView.backgroundColor?.cgColor
        } else {
            borderColorView.layer.borderColor = UIColor(resource: .ypWhite).cgColor
        }
    }
    
    func getColor() -> UIColor? {
        if isPressed {
            return colorView.backgroundColor
        } else {
            return nil
        }
    }
}


