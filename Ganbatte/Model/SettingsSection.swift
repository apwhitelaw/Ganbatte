//
//  SettingsSection.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 1/21/20.
//  Copyright © 2020 Austin Whitelaw. All rights reserved.
//

enum SettingsSection: Int, CaseIterable, CustomStringConvertible {
    
    case Lessons
    case Reviews
    
    var description: String {
        switch self {
        case .Lessons: return "Lessons"
        case .Reviews: return "Reviews"
        }
    }
}

enum LessonsOptions: Int, CaseIterable, CustomStringConvertible {
    case lessonsSize
    case lessonOrder
    
    var description: String {
        switch self {
        case .lessonsSize: return "Lesson Size"
        case .lessonOrder: return "Lesson Order"
        }
    }
}

enum ReviewssOptions: Int, CaseIterable, CustomStringConvertible {
    case notifications
    case email
    case reportCrashes
    
    var description: String {
        switch self {
        case .notifications: return "Notifications"
        case .email: return "Email"
        case .reportCrashes: return "Report Crashes"
        }
    }
}
