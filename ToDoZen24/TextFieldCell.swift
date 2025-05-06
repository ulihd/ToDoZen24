import UIKit

// MARK: - TextFieldCell Class
// Defines a custom UITableViewCell for adding new tasks, containing a text field for user input and communicating with the ViewController via delegation.
class TextFieldCell: UITableViewCell {
    
    // MARK: - Properties
    // The text field for entering new task descriptions and a weak reference to the ViewController delegate.
    let textField = UITextField()
    weak var delegate: ViewController?
    
    // MARK: - Initialization
    // Sets up the cell with a reuse identifier and configures the text field.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupTextField()
    }
    
    // MARK: - Initialization
    // Required initializer for storyboard decoding, not implemented as the cell is created programmatically.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    // Configures the text field’s frame, delegate, and editing actions, adding it to the cell’s content view.
    private func setupTextField() {
        textField.frame = contentView.bounds.insetBy(dx: 15, dy: 0)
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        contentView.addSubview(textField)
    }
    
    // MARK: - Actions
    // Notifies the delegate when the text field’s content changes, passing the current text.
    @objc private func textFieldChanged() {
        delegate?.textFieldDidChange(textField.text)
    }
    
    // MARK: - Cell Reuse
    // Resets the text field’s state (text, placeholder, interaction) when the cell is reused.
    override func prepareForReuse() {
        super.prepareForReuse()
        textField.text = nil
        textField.placeholder = "Tap to add new task"
        textField.isUserInteractionEnabled = true
    }
}

// MARK: - UITextFieldDelegate
// Handles text field interactions, such as dismissing the keyboard and saving new tasks when editing ends.
extension TextFieldCell: UITextFieldDelegate {
    
    // Resigns the text field as the first responder when the return key is pressed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Saves the text field’s content as a new task via the delegate if the text is non-empty, then clears the text field.
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, !text.isEmpty, let delegate = delegate else { return }
        delegate.didAddTask(text) // Calls ViewController's method
        textField.text = ""
    }
}
