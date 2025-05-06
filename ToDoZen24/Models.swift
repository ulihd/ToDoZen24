import Foundation

// MARK: - TodoItem Struct
// Represents a single to-do item with a unique identifier, description, and completion status, conforming to Codable for serialization and Identifiable for SwiftUI compatibility.
struct TodoItem: Codable, Identifiable {
    
    // MARK: - Properties
    // Unique identifier, task description, and completion status for the to-do item.
    let id: UUID
    var description: String
    var completed: Bool
    
    // MARK: - Initialization
    // Initializes a new to-do item with a generated UUID, provided description, and optional completion status (defaults to false).
    init(description: String, completed: Bool = false) {
        self.id = UUID()
        self.description = description
        self.completed = completed
    }
}

// MARK: - Date Extension
// Provides utility methods for formatting dates and navigating to the next or previous day.
extension Date {
    
    // MARK: - Formatting
    // Converts the date to a string using the specified format (e.g., "yyyy-MM-dd" or "EEE, dd MMM yyyy").
    func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // MARK: - Navigation
    // Returns the date for the next day by adding one day to the current date.
    func nextDay() -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: self)!
    }
    
    // Returns the date for the previous day by subtracting one day from the current date.
    func previousDay() -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: self)!
    }
}
