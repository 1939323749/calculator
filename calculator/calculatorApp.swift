//
//  calculatorApp.swift
//  calculator
//
//  Created by mba on 2023/10/10.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct calculatorApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Result.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task{
                    try? Tips.configure([
                        .displayFrequency(.immediate),
                        .datastoreLocation(.applicationDefault)
                    ])
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
