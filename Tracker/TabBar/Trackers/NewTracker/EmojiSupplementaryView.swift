import UIKit

final class EmojiSupplementaryView: UICollectionReusableView {
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
