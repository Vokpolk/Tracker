import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Private Properties
    private var category: String? = nil
    private var viewModel: CategoryViewModel?
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("new category", comment: "")
        label.textColor = UIColor(resource: .ypBlack)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var enterCategoryName: UITextField = {
        let enterTrackerName = UITextField()
        enterTrackerName.placeholder = NSLocalizedString("input category name", comment: "")
        enterTrackerName.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: enterTrackerName.frame.height))
        enterTrackerName.leftViewMode = .always
        enterTrackerName.backgroundColor = UIColor(resource: .ypBackground)
        enterTrackerName.layer.cornerRadius = 16
        enterTrackerName.clearButtonMode = .whileEditing
        enterTrackerName.addTarget(
            self,
            action: #selector(Self.textFieldDidReturn),
            for: .editingDidEndOnExit
        )
        enterTrackerName.addTarget(
            self,
            action: #selector(Self.textFieldDidReturn),
            for: .editingDidEnd
        )
        enterTrackerName.addTarget(
            self,
            action: #selector(Self.isCategoryExists),
            for: .editingChanged
        )
        return enterTrackerName
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("ready", comment: ""), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(resource: .ypGray)
        button.isEnabled = false
        button.setTitleColor(.ypWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(
            self,
            action: #selector(Self.readyButtonTap),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var isExistsLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("category exists", comment: "")
        label.textColor = UIColor(resource: .ypRed)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardEvent()
        initUIObjects()
    }
    
    // MARK: - Initializers
    func initialize(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        bind()
    }
    
    // MARK: - Private Methods
    private func bind() {
        guard let viewModel = viewModel else { return }
        
        viewModel.onCategoryNameCreate = { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    private func initUIObjects() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        [
            categoryLabel,
            enterCategoryName,
            isExistsLabel,
            addCategoryButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            categoryLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            categoryLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 25),
            
            enterCategoryName.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 38),
            enterCategoryName.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            enterCategoryName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            enterCategoryName.heightAnchor.constraint(equalToConstant: 75),
            
            isExistsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            isExistsLabel.topAnchor.constraint(equalTo: enterCategoryName.bottomAnchor, constant: 25),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func handleEnterPressed(_ categoryName: String?) {
        guard let categoryName else { return }
        print(categoryName)
        if !categoryName.isEmpty && isExistsLabel.isHidden {
            category = categoryName
            addCategoryButton.backgroundColor = UIColor(resource: .ypBlack)
            addCategoryButton.isEnabled = true
        } else {
            category = nil
            addCategoryButton.backgroundColor = UIColor(resource: .ypGray)
            addCategoryButton.isEnabled = false
        }
    }
    
    @objc private func readyButtonTap() {
        guard let category else { return }
        viewModel?.didEnter(category)
    }
    
    @objc func textFieldDidReturn(_ textField: UITextField) {
        enterCategoryName.resignFirstResponder()
        handleEnterPressed(textField.text)
    }
    
    @objc func isCategoryExists(_ textField: UITextField) {
        guard let viewModel else { return }
        if viewModel.isCategoryExists(textField.text ?? "") {
            isExistsLabel.isHidden = false
            addCategoryButton.isEnabled = false
            addCategoryButton.backgroundColor = UIColor(resource: .ypGray)
        } else {
            isExistsLabel.isHidden = true
            addCategoryButton.isEnabled = true
            addCategoryButton.backgroundColor = UIColor(resource: .ypBlack)
        }
    }
    
    private func hideKeyboardEvent() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}
