//
//  Constants.swift
//  To-Do
//
//  Created by Tom Wright on 24/4/2025.
//


import UIKit

// MARK: - Constants
// Defines shared constants used across the app to ensure consistency and avoid duplication.
struct Constants {
    
    // MARK: - Layout
    // Constants for cell layout dimensions.
    static let padding: CGFloat = 10
    static let radioSize: CGFloat = 16
    static let copyButtonSize: CGFloat = 30
    static let defaultRowHeight: CGFloat = 44
    
    // MARK: - Fonts
    // Fonts used for task text display and editing.
    static let taskFont = UIFont.systemFont(ofSize: 17)
    
    // MARK: - Date Format
    // Standard date format for keys and display.
    static let dateFormat = "yyyy-MM-dd"
}