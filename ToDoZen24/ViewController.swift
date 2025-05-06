import UIKit
import FSCalendar

// MARK: - ViewController Class
// Serves as the main view controller for the to-do app, managing the UI, calendar, task list, and user interactions, while coordinating with TodoDataManager and TodoTableViewManager.
class ViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    
    // MARK: - Properties
    // UI components for date display, navigation, calendar, and task list, plus data management and date tracking.
    private let dateLabel = UILabel()
    private let prevButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let prevYearButton = UIButton(type: .system)
    private let nextYearButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let calendarView = FSCalendar()
    
    private let dataManager = TodoDataManager()
    private lazy var tableViewManager = TodoTableViewManager(tableView: tableView, dataManager: dataManager, delegate: self)
    
    var currentDate = Date()
    private let dateFormatter = DateFormatter()
    
    // MARK: - UI Updates
    // Updates the date label to display the current date in the format "EEE, dd MMM yyyy".
    private func updateDateLabel() {
        dateLabel.text = currentDate.toString(format: "EEE, dd MMM yyyy")
    }
    
    // MARK: - Navigation Actions
    // Moves the current date to the previous day and refreshes the UI.
    @objc private func prevDay() {
        currentDate = currentDate.previousDay()
        updateDateLabel()
        tableView.reloadData()
    }
    
    // Moves the current date to the next day and refreshes the UI.
    @objc private func nextDay() {
        currentDate = currentDate.nextDay()
        updateDateLabel()
        tableView.reloadData()
    }
    
    // Shifts the calendar view back one year and logs the new month/year.
    @objc private func prevYear() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = -1
        if let newDate = calendar.date(byAdding: components, to: calendarView.currentPage, wrappingComponents: false) {
            calendarView.setCurrentPage(newDate, animated: true)
            print("Moved calendar back to: \(newDate.toString(format: "MMMM yyyy"))")
        }
    }
    
    // Shifts the calendar view forward one year and logs the new month/year.
    @objc private func nextYear() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 1
        if let newDate = calendar.date(byAdding: components, to: calendarView.currentPage, wrappingComponents: false) {
            calendarView.setCurrentPage(newDate, animated: true)
            print("Moved calendar forward to: \(newDate.toString(format: "MMMM yyyy"))")
        }
    }
    
    // Toggles the visibility of the calendar view and adjusts the table view’s position.
    @objc private func showCalendar() {
        calendarView.isHidden = !calendarView.isHidden
        updateTableViewPosition()
    }
    
    // Dismisses the keyboard when tapping outside the table view.
    @objc private func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: view)
        if !tableView.frame.contains(location) {
            view.endEditing(true)
        }
    }
    
    // Saves any pending task input when the app is about to resign active.
    @objc private func savePendingTask() {
        tableViewManager.savePendingTask(currentDate: currentDate)
    }
    
    // Updates the table view’s frame based on the calendar’s visibility, ensuring proper layout.
    private func updateTableViewPosition() {
        let calendarHeight: CGFloat = 300
        let tableTop: CGFloat = calendarView.isHidden ? 100 : 100 + calendarHeight
        tableView.frame = CGRect(
            x: 0,
            y: tableTop,
            width: view.frame.width,
            height: view.frame.height - tableTop
        )
        tableView.isUserInteractionEnabled = true
        print("Table view frame updated to: \(tableView.frame), interaction enabled: \(tableView.isUserInteractionEnabled)")
    }
    
    // MARK: - View Lifecycle
    // Sets up the UI, loads tasks, and configures gesture recognizers and notifications on view load.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        dataManager.loadTodos()
        updateDateLabel()
        tableView.reloadData()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(savePendingTask), name: UIApplication.willResignActiveNotification, object: nil)
        
        calendarView.isHidden = true
        updateTableViewPosition()
    }
    
    // Cleans up notification observers when the view controller is deallocated.
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setup
    // Configures the appearance, layout, and interactions of UI components (date label, buttons, calendar, table view).
    private func setupUI() {
        view.backgroundColor = .white
        
        dateFormatter.dateFormat = "EEE, dd MMM yyyy"
        dateLabel.textAlignment = .center
        dateLabel.isUserInteractionEnabled = true
        dateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCalendar)))
        view.addSubview(dateLabel)
        
        prevButton.setTitle("<", for: .normal)
        prevButton.addTarget(self, action: #selector(prevDay), for: .touchUpInside)
        view.addSubview(prevButton)
        
        nextButton.setTitle(">", for: .normal)
        nextButton.addTarget(self, action: #selector(nextDay), for: .touchUpInside)
        view.addSubview(nextButton)
        
        prevYearButton.setTitle("<<", for: .normal)
        prevYearButton.addTarget(self, action: #selector(prevYear), for: .touchUpInside)
        view.addSubview(prevYearButton)
        
        nextYearButton.setTitle(">>", for: .normal)
        nextYearButton.addTarget(self, action: #selector(nextYear), for: .touchUpInside)
        view.addSubview(nextYearButton)
        
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.scope = .month
        calendarView.appearance.headerDateFormat = "MMMM yyyy"
        calendarView.appearance.weekdayTextColor = .gray
        calendarView.appearance.todayColor = .orange
        calendarView.appearance.selectionColor = .blue
        view.addSubview(calendarView)
        
        tableView.dataSource = tableViewManager
        tableView.delegate = tableViewManager
        tableView.allowsSelection = true
        tableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        view.addSubview(tableView)
        
        dateLabel.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: 40)
        prevButton.frame = CGRect(x: 60, y: 50, width: 40, height: 40)
        nextButton.frame = CGRect(x: view.frame.width - 100, y: 50, width: 40, height: 40)
        prevYearButton.frame = CGRect(x: 20, y: 50, width: 40, height: 40)
        nextYearButton.frame = CGRect(x: view.frame.width - 60, y: 50, width: 40, height: 40)
        calendarView.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 300)
    }
    
    // MARK: - FSCalendarDelegate
    // Handles calendar date selection, updating the current date and UI accordingly.
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = date
        updateDateLabel()
        tableView.reloadData()
        calendarView.isHidden = true
        updateTableViewPosition()
    }
    
    // MARK: - FSCalendarDataSource
    // Provides the number of tasks (events) for each date, displayed as dots on the calendar.
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateKey = date.toString(format: "yyyy-MM-dd")
        return dataManager.todos[dateKey]?.count ?? 0
    }
    
    // MARK: - Task Management
    // Refreshes the calendar when tasks are added or edited to update event dots.
    func didAddOrEditTask() {
        calendarView.reloadData()
    }
    
    // Forwards text field changes to the table view manager for handling new task input.
    func textFieldDidChange(_ text: String?) {
        tableViewManager.textFieldDidChange(text)
    }
    
    // Adds a new task via the table view manager.
    func didAddTask(_ text: String) {
        tableViewManager.didAddTask(text)
    }
    
    // Edits an existing task at the specified index path via the table view manager.
    func didEditTask(_ text: String, at indexPath: IndexPath) {
        tableViewManager.didEditTask(text, at: indexPath)
    }
    
    // Toggles the completion status of a task at the specified index path.
    func toggleCompletion(at indexPath: IndexPath) {
        tableViewManager.toggleCompletion(at: indexPath)
    }
    
    // Copies a task to the next day via the table view manager.
    func copyTaskToNextDay(at indexPath: IndexPath) {
        tableViewManager.copyTaskToNextDay(at: indexPath)
    }
}
