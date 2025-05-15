// TodoTableViewManager.swift
// Manages the UITableView’s data source, delegate, and drag interactions for the to-do list.

// MARK: - Imports
import UIKit

// MARK: - TodoTableViewManager
// Handles table view data source, delegate, drag-and-drop, and task operations.
class TodoTableViewManager: NSObject, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate {
    // MARK: Properties
    private weak var tableView: UITableView?
    private let dataManager: TodoDataManager
    private weak var delegate: ViewController?
    private var isAddingNewTask = false
    private var editingIndexPath: IndexPath?
    private var copiedTasks: [String: Set<Int>] = [:] // dateKey: Set<rowIndex>
    
    // MARK: Initialization
    init(tableView: UITableView, dataManager: TodoDataManager, delegate: ViewController) {
        self.tableView = tableView
        self.dataManager = dataManager
        self.delegate = delegate
        super.init()
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let delegate = delegate else { return 0 }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        let taskCount = dataManager.todos[dateKey]?.count ?? 0
        return taskCount + (isAddingNewTask ? 2 : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let delegate = delegate else { return UITableViewCell() }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        let taskCount = dataManager.todos[dateKey]?.count ?? 0
        
        if indexPath.row < taskCount {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
            if let item = dataManager.todos[dateKey]?[indexPath.row] {
                let isEditing = editingIndexPath == indexPath
                let isCopied = copiedTasks[dateKey]?.contains(indexPath.row) ?? false
                cell.configure(with: item, isEditing: isEditing, indexPath: indexPath, delegate: delegate, isCopied: isCopied)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldCell", for: indexPath) as! TextFieldCell
            cell.textField.placeholder = "Tap to add new task"
            cell.delegate = delegate
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        let taskCount = dataManager.todos[dateKey]?.count ?? 0
        
        print("Table view tapped at \(indexPath)")
        if indexPath.row < taskCount {
            print("Selected existing task at \(indexPath) for editing")
            editingIndexPath = indexPath
            if let cell = tableView.cellForRow(at: indexPath) as? TodoCell,
               let item = dataManager.todos[dateKey]?[indexPath.row] {
                cell.configure(with: item, isEditing: true, indexPath: indexPath, delegate: delegate, isCopied: copiedTasks[dateKey]?.contains(indexPath.row) ?? false)
                print("Cell state after configure - hidden: \(cell.textField.isHidden), enabled: \(cell.textField.isUserInteractionEnabled)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let success = cell.textField.becomeFirstResponder()
                    print("Text field focused at \(indexPath): \(success)")
                }
            } else {
                print("Failed to get TodoCell or item at \(indexPath)")
            }
        } else {
            if let cell = tableView.cellForRow(at: indexPath) as? TextFieldCell {
                print("Selected new task row at \(indexPath)")
                cell.textField.becomeFirstResponder()
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let delegate = delegate else { return 44 }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        let taskCount = dataManager.todos[dateKey]?.count ?? 0
        
        if indexPath.row < taskCount, let item = dataManager.todos[dateKey]?[indexPath.row] {
            let padding: CGFloat = 10
            let radioSize: CGFloat = 16
            let buttonSize: CGFloat = 30
            let availableWidth = tableView.bounds.width - (padding + radioSize + padding + buttonSize + padding)
            let font = UIFont.systemFont(ofSize: 17)
            let text = item.description
            let constraintRect = CGSize(width: availableWidth, height: .greatestFiniteMagnitude)
            let boundingBox = text.boundingRect(
                with: constraintRect,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                attributes: [NSAttributedString.Key.font: font],
                context: nil as NSStringDrawingContext?
            )
            let textHeight = ceil(boundingBox.height)
            let totalHeight = textHeight + 2 * padding
            return max(44, totalHeight)
        }
        return 44
    }
    
    // MARK: - UITableViewDragDelegate
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let delegate = delegate else { return [] }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        let taskCount = dataManager.todos[dateKey]?.count ?? 0
        
        if indexPath.row < taskCount {
            let itemProvider = NSItemProvider(object: NSString(string: "task"))
            let dragItem = UIDragItem(itemProvider: itemProvider)
            dragItem.localObject = indexPath
            print("Drag started at \(indexPath)")
            return [dragItem]
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let delegate = delegate else { return }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        dataManager.moveTodo(from: sourceIndexPath.row, to: destinationIndexPath.row, for: dateKey)
        if var copiedSet = copiedTasks[dateKey] {
            copiedSet.remove(sourceIndexPath.row)
            if copiedSet.contains(destinationIndexPath.row) {
                copiedSet.insert(destinationIndexPath.row)
            }
            copiedTasks[dateKey] = copiedSet
        }
        tableView.reloadData()
        print("Moved item from \(sourceIndexPath) to \(destinationIndexPath)")
    }
    
    // MARK: - Swipe Actions
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let delegate = delegate else { return false }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        let taskCount = dataManager.todos[dateKey]?.count ?? 0
        let canEdit = indexPath.row < taskCount
        print("Can edit row at \(indexPath): \(canEdit)")
        return canEdit
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let delegate = delegate else { return nil }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        let taskCount = dataManager.todos[dateKey]?.count ?? 0
        
        print("Swipe action requested at \(indexPath)")
        if indexPath.row < taskCount {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
                guard let self = self else { return }
                self.dataManager.deleteTodo(at: indexPath.row, for: dateKey)
                if var copiedSet = self.copiedTasks[dateKey] {
                    copiedSet.remove(indexPath.row)
                    self.copiedTasks[dateKey] = copiedSet
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                delegate.didAddOrEditTask()
                print("Deleted item at \(indexPath)")
                completion(true)
            }
            return UISwipeActionsConfiguration(actions: [deleteAction])
        }
        return nil
    }
    
    // MARK: - Task Management
    func didAddTask(_ text: String) {
        guard let delegate = delegate else { return }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        dataManager.addTodo(text, for: dateKey)
        isAddingNewTask = false
        tableView?.reloadData()
        delegate.didAddOrEditTask()
        print("Added task: \(text)")
    }
    
    func didEditTask(_ text: String, at indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        dataManager.editTodo(text, at: indexPath.row, for: dateKey)
        if var copiedSet = copiedTasks[dateKey] {
            copiedSet.remove(indexPath.row)
            copiedTasks[dateKey] = copiedSet
        }
        editingIndexPath = nil
        tableView?.reloadRows(at: [indexPath], with: .automatic)
        delegate.didAddOrEditTask()
        print("Edited task at \(indexPath) to: \(text)")
    }
    
    func textFieldDidChange(_ text: String?) {
        guard let delegate = delegate else { return }
        let wasAdding = isAddingNewTask
        isAddingNewTask = !(text?.isEmpty ?? true)
        if !wasAdding && isAddingNewTask {
            let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
            let taskCount = dataManager.todos[dateKey]?.count ?? 0
            let newRowIndexPath = IndexPath(row: taskCount + 1, section: 0)
            tableView?.insertRows(at: [newRowIndexPath], with: .automatic)
            print("Inserted new row at \(newRowIndexPath)")
        }
    }
    
    func toggleCompletion(at indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        dataManager.toggleTodoCompletion(at: indexPath.row, for: dateKey)
        tableView?.reloadRows(at: [indexPath], with: .automatic)
        delegate.didAddOrEditTask()
        print("Toggled completion at \(indexPath)")
    }
    
    func copyTaskToTomorrow(at indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        let dateKey = delegate.currentDate.toString(format: "yyyy-MM-dd")
        let tomorrow = Date().nextDay()
        let tomorrowKey = tomorrow.toString(format: "yyyy-MM-dd")
        dataManager.copyTodo(at: indexPath.row, from: dateKey, to: tomorrowKey)
        if copiedTasks[dateKey] == nil { copiedTasks[dateKey] = [] }
        copiedTasks[dateKey]?.insert(indexPath.row)
        tableView?.reloadRows(at: [indexPath], with: .automatic)
        delegate.didAddOrEditTask()
        print("Copied task at \(indexPath) from \(dateKey) to tomorrow (\(tomorrowKey))")
    }
    
    func savePendingTask(currentDate: Date) {
        guard delegate != nil else { return }
        let dateKey = currentDate.toString(format: "yyyy-MM-dd")
        let taskCount = dataManager.todos[dateKey]?.count ?? 0
        for row in taskCount..<tableView!.numberOfRows(inSection: 0) {
            if let cell = tableView!.cellForRow(at: IndexPath(row: row, section: 0)) as? TextFieldCell,
               let text = cell.textField.text, !text.isEmpty {
                didAddTask(text)
                cell.textField.text = ""
            }
        }
        if let indexPath = editingIndexPath,
           let cell = tableView!.cellForRow(at: indexPath) as? TodoCell,
           let text = cell.textField.text, !text.isEmpty {
            didEditTask(text, at: indexPath)
            cell.textField.text = ""
        }
    }
}
