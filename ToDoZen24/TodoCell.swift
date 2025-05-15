// TodoCell.swift
// Custom table view cell for displaying a to-do item with a title, radio button, and copy button.

// MARK: - Imports
import UIKit

// MARK: - TodoCell
// A table view cell that displays a to-do item’s title, a toggleable radio button, and a copy button.
class TodoCell: UITableViewCell {
    // MARK: Properties
    let radioButton = UIButton(type: .custom)
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.isHidden = true
        textField.isUserInteractionEnabled = false
        return textField
    }()
    
    let copyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()
    
    weak var delegate: ViewController?
    
    // MARK: Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup UI
    // Configures the appearance and layout of UI components.
    private func setupUI() {
        // Radio button for marking tasks complete
        radioButton.layer.cornerRadius = 8
        radioButton.layer.borderWidth = 1
        radioButton.layer.borderColor = UIColor.gray.cgColor
        radioButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        contentView.addSubview(radioButton)
        
        // Copy button with right arrow icon
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
        contentView.addSubview(copyButton)
        
        // Label for displaying task description
        contentView.addSubview(label)
        
        // Text field for editing task description
        textField.delegate = self
        contentView.addSubview(textField)
    }
    
    // MARK: Layout
    // Adjusts the frames of UI components based on the cell’s size.
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
    
    // MARK: Configuration
    // Updates the cell’s UI based on the to-do item’s data, editing state, and copy status.
    func configure(with item: TodoItem, isEditing: Bool, indexPath: IndexPath, delegate: ViewController, isCopied: Bool) {
        self.delegate = delegate
        
        // Configure radio button
        radioButton.subviews.forEach { if $0.tag == 999 { $0.removeFromSuperview() } }
        if item.completed {
            let dot = UIView(frame: CGRect(x: 4, y: 4, width: 8, height: 8))
            dot.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            dot.layer.cornerRadius = 4
            dot.tag = 999
            radioButton.addSubview(dot)
            radioButton.accessibilityLabel = "Completed"
        } else {
            radioButton.backgroundColor = .clear
            radioButton.accessibilityLabel = "Not completed"
        }
        
        // Set copy button color
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
    
    // MARK: Actions
    // Handles radio button and copy button taps.
    @objc private func radioButtonTapped() {
        guard let tableView = superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else {
            print("Failed to get current indexPath for cell")
            return
        }
        print("Radio button tapped at \(indexPath)")
        delegate?.toggleCompletion(at: indexPath)
    }
    
    @objc private func copyButtonTapped() {
        guard let tableView = superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else {
            print("Failed to get current indexPath for copy")
            return
        }
        print("Copy button tapped at \(indexPath)")
        delegate?.copyTaskToTomorrow(at: indexPath)
    }
}

// MARK: - UITextFieldDelegate
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
