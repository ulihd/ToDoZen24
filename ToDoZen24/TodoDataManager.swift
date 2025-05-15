// TodoDataManager.swift
// Manages the storage and retrieval of to-do items, persisting them to UserDefaults as JSON data.

// MARK: - Imports
import Foundation

// MARK: - Data Manager
// Manages to-do items, organized by date, with persistence and task operations.
class TodoDataManager {
    // MARK: Properties
    var todos: [String: [TodoItem]] = [:] // Date key (yyyy-MM-dd) to array of to-do items
    
    // MARK: Initialization
    init() {
        loadTodos()
    }
    
    // MARK: Persistence
    // Saves the todos dictionary to UserDefaults by encoding it as JSON data.
    func saveTodos() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(todos) {
            UserDefaults.standard.set(data, forKey: "todos")
        }
    }
    
    // Loads to-do items from UserDefaults, decoding the JSON data into the todos dictionary.
    func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: "todos") {
            let decoder = JSONDecoder()
            if let loadedTodos = try? decoder.decode([String: [TodoItem]].self, from: data) {
                todos = loadedTodos
            }
        }
    }
    
    // MARK: Task Management
    // Adds a new to-do item for a specific date.
    func addTodo(_ text: String, for dateKey: String) {
        let todo = TodoItem(description: text)
        if var existingTodos = todos[dateKey] {
            existingTodos.append(todo)
            todos[dateKey] = existingTodos
        } else {
            todos[dateKey] = [todo]
        }
        saveTodos()
    }
    
    // Edits the description of a to-do item at the specified index for a date.
    func editTodo(_ text: String, at index: Int, for dateKey: String) {
        guard var items = todos[dateKey], index >= 0, index < items.count else { return }
        items[index].description = text
        todos[dateKey] = items
        saveTodos()
    }
    
    // Toggles the completion state of a to-do item at the specified index for a date.
    func toggleTodoCompletion(at index: Int, for dateKey: String) {
        guard var items = todos[dateKey], index >= 0, index < items.count else { return }
        items[index].completed.toggle()
        todos[dateKey] = items
        saveTodos()
    }
    
    // Copies a to-do item to another date.
    func copyTodo(at index: Int, from sourceDate: String, to targetDate: String) {
        guard var sourceTodos = todos[sourceDate], index >= 0, index < sourceTodos.count else { return }
        let task = TodoItem(description: sourceTodos[index].description, completed: false)
        if var targetTodos = todos[targetDate] {
            targetTodos.append(task)
            todos[targetDate] = targetTodos
        } else {
            todos[targetDate] = [task]
        }
        saveTodos()
    }
    
    // Deletes a to-do item at the specified index for a date.
    func deleteTodo(at index: Int, for dateKey: String) {
        guard var items = todos[dateKey], index >= 0, index < items.count else { return }
        items.remove(at: index)
        todos[dateKey] = items.isEmpty ? nil : items
        saveTodos()
    }
    
    // Moves a to-do item within the same date from one index to another.
    func moveTodo(from sourceIndex: Int, to destinationIndex: Int, for dateKey: String) {
        guard var items = todos[dateKey], sourceIndex >= 0, sourceIndex < items.count, destinationIndex >= 0, destinationIndex < items.count else { return }
        let movedItem = items.remove(at: sourceIndex)
        items.insert(movedItem, at: destinationIndex)
        todos[dateKey] = items
        saveTodos()
    }
}
