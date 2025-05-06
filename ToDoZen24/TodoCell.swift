import UIKit

// MARK: - TodoCell Class
// Defines a custom UITableViewCell for displaying to-do items, including a radio button for completion, a label for task display, a text field for editing, and a copy button to move the task to the next day.
class TodoCell: UITableViewCell {
    
    // MARK: - Properties
    // UI components and delegate for interaction with the ViewController.
    let radioButton = UIButton(type: .custom)
    let label = UILabel()
    let textField = UITextField()
    let copyButton = UIButton(type: .system)
    weak var delegate: ViewController?
    
    // MARK: - Initialization
    // Sets up the cell with a reuse identifier and initializes the UI.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    // Configures the appearance and layout of UI components (radio button, label, text field, copy button).
    private func setupUI() {
        // Radio button for marking tasks complete
        radioButton.layer.cornerRadius = 8
        radioButton.layer.borderWidth = 1
        radioButton.layer.borderColor = UIColor.gray.cgColor
        radioButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        contentView.addSubview(radioButton)
        
        // Copy button with right arrow icon
        copyButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        copyButton.tintColor = .systemBlue
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        contentView.addSubview(copyButton)
        
        // Label for displaying task description
        label.numberOfLines = 0 // Allow multiple lines for wrapping
        label.lineBreakMode = .byWordWrapping
        contentView.addSubview(label)
        
        // Text field for editing task description
        textField.delegate = self
        textField.isHidden = true
        textField.isUserInteractionEnabled = false
        contentView.addSubview(textField)
    }
    
    // MARK: - Layout
    // Adjusts the frames of UI components based on the cell’s size, ensuring text wraps and fits.
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 10
        let radioSize: CGFloat = 16
        let buttonSize: CGFloat = 30
        let availableWidth = contentView.bounds.width - (padding + radioSize + padding + buttonSize + padding)
        
        radioButton.frame = CGRect(
            x: padding,
            y: (contentView.bounds.height - radioSize) / 2,
            width: radioSize,
            height: radioSize
        )
        
        copyButton.frame = CGRect(
            x: contentView.bounds.width - buttonSize - padding,
            y: (contentView.bounds.height - buttonSize) / 2,
            width: buttonSize,
            height: buttonSize
        )
        
        label.frame = CGRect(
            x: padding + radioSize + padding,
            y: padding,
            width: availableWidth,
            height: contentView.bounds.height - 2 * padding
        )
        
        textField.frame = CGRect(
            x: padding + radioSize + padding,
            y: padding,
            width: availableWidth,
            height: contentView.bounds.height - 2 * padding
        )
    }
    
    // MARK: - Configuration
    // Updates the cell’s UI based on the to-do item’s data, editing state, and copy status.
    func configure(with item: TodoItem, isEditing: Bool, indexPath: IndexPath, delegate: ViewController, isCopied: Bool) {
        self.delegate = delegate
        
        // Configure radio button (completion dot)
        radioButton.subviews.forEach { if $0.tag == 999 { $0.removeFromSuperview() } }
        if item.completed {
            let dot = UIView(frame: CGRect(x: 4, y: 4, width: 8, height: 8))
            dot.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            dot.layer.cornerRadius = 4
            dot.tag = 999
            radioButton.addSubview(dot)
        } else {
            radioButton.backgroundColor = .clear
        }
        
        // Set copy button color (grey if copied, blue if not)
        copyButton.tintColor = isCopied ? .systemGray : .systemBlue
        
        // Configure label or text field
        if isEditing {
            label.isHidden = true
            textField.isHidden = false
            textField.text = item.description
            textField.isUserInteractionEnabled = true
            contentView.bringSubviewToFront(textField)
            print("Configuring \(indexPath) for editing: \(item.description), textField hidden: \(textField.isHidden), enabled: \(textField.isUserInteractionEnabled)")
        } else {
            label.isHidden = false
            textField.isHidden = true
            textField.isUserInteractionEnabled = false
            let attributedText = NSAttributedString(
                string: item.description,
                attributes: item.completed ? [.strikethroughStyle: NSUnderlineStyle.single.rawValue] : [:]
            )
            label.attributedText = attributedText
            print("Configuring \(indexPath) as label: \(item.description), completed: \(item.completed), copied: \(isCopied)")
        }
    }
    
    // MARK: - Actions
    // Handles user interactions with the radio button and copy button.
    @objc private func radioButtonTapped() {
        guard let tableView = superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else {
            print("Failed to get current indexPath for cell")
            return
        }
        print("Radio button tapped at \(indexPath), target still set: \(radioButton.allTargets.count > 0)")
        delegate?.toggleCompletion(at: indexPath)
    }
    
    @objc private func copyButtonTapped() {
        guard let tableView = superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else {
            print("Failed to get current indexPath for copy")
            return
        }
        print("Copy button tapped at \(indexPath)")
        delegate?.copyTaskToNextDay(at: indexPath)
    }
}

// MARK: - UITextFieldDelegate
// Manages text field behavior for editing tasks.
extension TodoCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty, let delegate = delegate,
              let tableView = superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else {
            print("Text field ended editing but no save: text=\(textField.text ?? "nil"), delegate=\(delegate != nil), indexPath unavailable")
            return
        }
        delegate.didEditTask(text, at: indexPath)
        print("Text field ended editing, saving: \(text) at \(indexPath)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
