import Foundation

// MARK: - TodoDataManager Class
// Manages the storage and retrieval of to-do items, persisting them to UserDefaults as JSON data.
class TodoDataManager {
    
    // MARK: - Properties
    // Stores to-do items as a dictionary mapping date strings (e.g., "yyyy-MM-dd") to arrays of TodoItem.
    var todos: [String: [TodoItem]] = [:]
    
    // MARK: - Persistence
    // Saves the todos dictionary to UserDefaults by encoding it as JSON data.
    func saveTodos() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(todos) {
            UserDefaults.standard.set(data, forKey: "todos")
        }
    }
    
    // MARK: - Persistence
    // Loads to-do items from UserDefaults, decoding the JSON data into the todos dictionary.
    func loadTodos() {
        if let data = UserDefaults.standard.data(forKey: "todos") {
            let decoder = JSONDecoder()
            if let loadedTodos = try? decoder.decode([String: [TodoItem]].self, from: data) {
                todos = loadedTodos
            }
        }
    }
}
