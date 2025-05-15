// ViewController.swift
// The main view controller for the ToDoZen24 app, managing the FSCalendar and UITableView for task display.

// MARK: - Imports
import UIKit
import FSCalendar

// MARK: - ViewController
// Manages the calendar and table view, handling user interactions for date selection and task management.
class ViewController: UIViewController {
    // MARK: Properties
    private let calendar = FSCalendar()
    private let tableView = UITableView()
    private let dataManager = TodoDataManager()
    private var tableViewManager: TodoTableViewManager!
    var currentDate = Date()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendar()
        setupGestures()
        setupTableView()
        dataManager.loadTodos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendar.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.bounds.width,
            height: calendar.scope == .month ? 300 : 100
        )
        tableView.frame = CGRect(
            x: 0,
            y: calendar.frame.maxY,
            width: view.bounds.width,
            height: view.bounds.height - calendar.frame.maxY - view.safeAreaInsets.bottom
        )
    }
    
    // MARK: Setup Methods
    // Configures the FSCalendar for date selection and appearance.
    private func setupCalendar() {
        calendar.delegate = self
        calendar.dataSource = self
        calendar.scope = .month
        calendar.appearance.headerDateFormat = "MMMM yyyy"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.weekdayTextColor = .gray
        calendar.appearance.selectionColor = .systemBlue
        calendar.appearance.todayColor = .systemOrange
        view.addSubview(calendar)
    }
    
    // Configures swipe gestures for navigating days and months.
    private func setupGestures() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRight.direction = .right
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        [swipeLeft, swipeRight, swipeUp, swipeDown].forEach { calendar.addGestureRecognizer($0) }
    }
    
    // Configures the UITableView for displaying tasks.
    private func setupTableView() {
        tableViewManager = TodoTableViewManager(tableView: tableView, dataManager: dataManager, delegate: self)
        tableView.dataSource = tableViewManager
        tableView.delegate = tableViewManager
        tableView.register(TodoCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: "TextFieldCell")
        view.addSubview(tableView)
    }
    
    // MARK: Actions
    // Handles swipe gestures to navigate days and months.
    @objc private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        
        switch gesture.direction {
        case .left:
            currentDate = currentDate.nextDay()
            calendar.select(currentDate)
            tableView.reloadData()
            haptic.impactOccurred()
            print("Swiped to next day: \(currentDate.toString(format: "yyyy-MM-dd"))")
        case .right:
            currentDate = currentDate.previousDay()
            calendar.select(currentDate)
            tableView.reloadData()
            haptic.impactOccurred()
            print("Swiped to previous day: \(currentDate.toString(format: "yyyy-MM-dd"))")
        case .up:
            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
            calendar.setCurrentPage(nextMonth, animated: true)
            currentDate = nextMonth
            tableView.reloadData()
            haptic.impactOccurred()
            print("Swiped to next month: \(nextMonth.toString(format: "yyyy-MM-dd"))")
        case .down:
            let prevMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
            calendar.setCurrentPage(prevMonth, animated: true)
            currentDate = prevMonth
            tableView.reloadData()
            haptic.impactOccurred()
            print("Swiped to previous month: \(prevMonth.toString(format: "yyyy-MM-dd"))")
        default:
            break
        }
    }
    
    // MARK: Task Management
    // Updates the calendar’s event dots after tasks are added or edited.
    func didAddOrEditTask() {
        calendar.reloadData()
    }
    
    // Handles adding a new task for the current date.
    func didAddTask(_ text: String) {
        tableViewManager.didAddTask(text)
    }
    
    // Handles editing an existing task at the specified index path.
    func didEditTask(_ text: String, at indexPath: IndexPath) {
        tableViewManager.didEditTask(text, at: indexPath)
    }
    
    // Handles text field changes for adding new tasks.
    func textFieldDidChange(_ text: String?) {
        tableViewManager.textFieldDidChange(text)
    }
    
    // Toggles the completion status of a task at the specified index path.
    func toggleCompletion(at indexPath: IndexPath) {
        tableViewManager.toggleCompletion(at: indexPath)
    }
    
    // Copies a task to tomorrow’s date.
    func copyTaskToTomorrow(at indexPath: IndexPath) {
        tableViewManager.copyTaskToTomorrow(at: indexPath)
    }
}

// MARK: - FSCalendarDelegate
extension ViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = date
        tableView.reloadData()
        print("Selected date: \(date.toString(format: "yyyy-MM-dd"))")
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        currentDate = calendar.currentPage
        tableView.reloadData()
        print("Page changed to: \(currentDate.toString(format: "yyyy-MM-dd"))")
    }
}

// MARK: - FSCalendarDataSource
extension ViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateKey = date.toString(format: "yyyy-MM-dd")
        return dataManager.todos[dateKey]?.isEmpty == false ? 1 : 0
    }
}
