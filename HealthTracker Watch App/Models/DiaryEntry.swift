//
//  DiaryEntry.swift
//  HealthTracker
//
//  Created by Tim Terrance on 6/1/26.
//

import Foundation
import Combine
import SwiftUI

enum EntryType: String, Codable, CaseIterable{
    case water = "water"
    case calories = "calories"
    
    var color: Color {
        switch self {
        case .water: return Color.cyan
        case .calories: return Color.orange
        }
    }
}

struct DiaryEntry: Identifiable, Codable {
    let id: UUID
    let type: EntryType
    let value: Double
    let timestamp: Date
    
    init(id: UUID = UUID(), type: EntryType, value: Double, timestamp: Date = Date()) {
        self.id = id
        self.type = type
        self.value = value
        self.timestamp = timestamp
    }
}

