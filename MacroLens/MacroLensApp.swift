//
//  MacroLensApp.swift
//  MacroLens
//
//  Created by Rudra on 15/10/25.
//

import SwiftUI

@main
struct MacroLensApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                        .environmentObject(authViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
        }
    }
}
