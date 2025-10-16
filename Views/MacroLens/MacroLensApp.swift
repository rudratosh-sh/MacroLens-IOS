//
//  MacroLensApp.swift
//  MacroLens
//
//  Created by Rudra on 15/10/25.
//

import SwiftUI
import CoreData

@main
struct MacroLensApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
