//
//  TodoStorage.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 17.03.2026.
//


import Foundation

enum TodoStorage {
    private static let key = "todos"

    static func save(_ todos: [Todo]) {
        if let data = try? JSONEncoder().encode(todos) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> [Todo] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([Todo].self, from: data) {
            return decoded
        }
        return []
    }
}
