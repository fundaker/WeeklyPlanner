//
//  TaskStorage.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 17.03.2026.
//

import Foundation

enum TaskStorage {
    private static let key = "tasks"

    static func save(_ tasks: [Task]) {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Task save error:", error)
        }
    }

    static func load() -> [Task] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }

        do {
            return try JSONDecoder().decode([Task].self, from: data)
        } catch {
            print("Task load error:", error)
            return []
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
