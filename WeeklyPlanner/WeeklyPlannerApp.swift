//
//  WeeklyPlannerApp.swift
//  WeeklyPlanner
//
//  Created by Funda Aker on 10.03.2026.
//

import SwiftUI
import SwiftData

@main
struct WeeklyPlannerApp: App {

    let container: ModelContainer

    init() {
        let container = Persistence.makeContainer()
        MainActor.assumeIsolated {
            LegacyMigration.run(context: container.mainContext)
        }
        self.container = container
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
