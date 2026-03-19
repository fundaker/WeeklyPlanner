//
//  GoalStorage.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 17.03.2026.
//

import Foundation

enum GoalStorage {
    private static let key = "goals"

    static func save(_ goals: [Goal]) {
        if let data = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> [Goal] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            return decoded
        }
        return []
    }
}
