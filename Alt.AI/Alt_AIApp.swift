//
//  Alt_AIApp.swift
//  Alt.AI
//
//  Created by John Behnke on 2/3/24.
//

import SwiftUI
import SwiftData

@main
struct Alt_AIApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Prompt.self,
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
            MainView()
#if os(macOS)
                .fixedSize()
                .frame(width: 500, height: 700)
            
#endif
        }
        .windowResizability(.contentSize)
        .modelContainer(sharedModelContainer)
#if os(macOS)
        Settings {
            SettingsView()
                .frame(width: 400, height: 200)
        }
        .windowResizability(.automatic)
#endif
        
    }
}
