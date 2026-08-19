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

    @Environment(\.scenePhase) private var scenePhase

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
                .task {
                    await Reminders.requestAuthorization()
                    await Reminders.refresh(context: container.mainContext)
                }
        }
        .modelContainer(container)
        .onChange(of: scenePhase) { _, phase in
            // Öne gelirken: izin Ayarlar'dan açılmış ya da gün dönmüş olabilir.
            // Arkaya geçerken: oturum içindeki değişiklikler yansısın.
            guard phase == .active || phase == .background else { return }
            Task { await Reminders.refresh(context: container.mainContext) }
        }
    }
}
