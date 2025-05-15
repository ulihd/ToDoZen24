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
    private let toolbar = UIToolbar()
    private let dateButton = UIButton(type: .system)
    private let tableView = UITableView()
    private let dataManager = TodoDataManager()
    private var tableViewManager: TodoTableViewManager!
    private var isCalendarDayView = false
    var currentDate = Date()
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolbar()
        setupCalendar()
        setupTableView()
        dataManager.loadTodos()
        updateDateLabel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let toolbarHeight: CGFloat = 44
        let calendarHeight: CGFloat = isCalendarDayView ? 0 : 300
        
        toolbar.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: view.bounds.width,
            height: toolbarHeight
        )
        calendar.frame = CGRect(
            x: 0,
            y: toolbar.frame.maxY,
            width: view.bounds.width,
            height: calendarHeight
        )
        tableView.frame = CGRect(
            x: 0,
            y: isCalendarDayView ? toolbar.frame.maxY : calendar.frame.maxY,
            width: view.bounds.width,
            height: view.bounds.height - (isCalendarDayView ? toolbar.frame.maxY : calendar.frame.maxY) - view.safeAreaInsets.bottom
        )
    }
    
    // MARK: Setup Methods
    // Configures the toolbar with Today and date toggle button, with swipe gestures for navigation.
    private func setupToolbar() {
        let todayButton = UIBarButtonItem(
            title: "Today",
            style: .plain,
            target: self,
            action: #selector(returnToToday)
        )
        dateButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        dateButton.setTitleColor(.black, for: .normal)
        dateButton.addTarget(self, action: #selector(toggleCalendarVisibility), for: .touchUpInside)
        dateButton.sizeToFit()
        
        // Add swipe gestures for navigation
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(goToPreviousDay))
        swipeRight.direction = .right
        swipeRight.numberOfTouchesRequired = 1
        dateButton.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(goToNextDay))
        swipeLeft.direction = .left
        swipeLeft.numberOfTouchesRequired = 1
        dateButton.addGestureRecognizer(swipeLeft)
        
        let dateBarButton = UIBarButtonItem(customView: dateButton)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [todayButton, flexibleSpace, dateBarButton, flexibleSpace]
        view.addSubview(toolbar)
    }
    
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
    // Returns the calendar to the current day and shows its tasks.
    @objc private func returnToToday() {
        currentDate = Date()
        let todayMonth = Calendar.current.startOfMonth(for: currentDate)
        print("Setting todayMonth to: \(todayMonth.toString(format: "yyyy-MM-dd"))")
        if !isCalendarDayView {
            calendar.setCurrentPage(todayMonth, animated: true)
            calendar.select(currentDate)
        }
        tableView.reloadData()
        updateDateLabel()
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.impactOccurred()
        print("Returned to today: \(currentDate.toString(format: "yyyy-MM-dd"))")
    }
    
    // Navigates to the previous day.
    @objc private func goToPreviousDay() {
        if let previousDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) {
            currentDate = previousDate
            let currentMonth = Calendar.current.startOfMonth(for: currentDate)
            print("Navigating to previous day: \(currentDate.toString(format: "yyyy-MM-dd")), month: \(currentMonth.toString(format: "yyyy-MM-dd"))")
            if !isCalendarDayView {
                calendar.setCurrentPage(currentMonth, animated: true)
                calendar.select(currentDate)
            }
            tableView.reloadData()
            updateDateLabel()
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
        }
    }
    
    // Navigates to the next day.
    @objc private func goToNextDay() {
        if let nextDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) {
            currentDate = nextDate
            let currentMonth = Calendar.current.startOfMonth(for: currentDate)
            print("Navigating to next day: \(currentDate.toString(format: "yyyy-MM-dd")), month: \(currentMonth.toString(format: "yyyy-MM-dd"))")
            if !isCalendarDayView {
                calendar.setCurrentPage(currentMonth, animated: true)
                calendar.select(currentDate)
            }
            tableView.reloadData()
            updateDateLabel()
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.impactOccurred()
        }
    }
    
    // Toggles the calendar visibility between Month and Day views.
    @objc private func toggleCalendarVisibility() {
        isCalendarDayView.toggle()
        calendar.isHidden = isCalendarDayView
        if !isCalendarDayView {
            calendar.reloadData() // Refresh for Month view
            calendar.select(currentDate)
            let currentMonth = Calendar.current.startOfMonth(for: currentDate)
            calendar.setCurrentPage(currentMonth, animated: false)
        }
        view.setNeedsLayout()
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.impactOccurred()
        print("Calendar set to \(isCalendarDayView ? "day" : "month") view")
    }
    
    // Updates the date button with the current date.
    private func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy"
        dateButton.setTitle(formatter.string(from: currentDate), for: .normal)
        dateButton.sizeToFit()
        print("Updated date button to: \(dateButton.title(for: .normal) ?? "nil")")
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
        updateDateLabel()
        print("Selected date: \(currentDate.toString(format: "yyyy-MM-dd"))")
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        if calendar.selectedDate == nil {
            currentDate = calendar.currentPage
            tableView.reloadData()
            updateDateLabel()
            print("Page changed to: \(currentDate.toString(format: "yyyy-MM-dd"))")
        }
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if isCalendarDayView {
            // In Day view, disable selection since calendar is hidden
            return false
        }
        return true
    }
}

// MARK: - FSCalendarDataSource
extension ViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateKey = date.toString(format: "yyyy-MM-dd")
        return dataManager.todos[dateKey]?.isEmpty == false ? 1 : 0
    }
}

// MARK: - Calendar Extension
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        var calendar = self
        calendar.timeZone = TimeZone(identifier: "Australia/Sydney") ?? .current
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components)!
    }
}
