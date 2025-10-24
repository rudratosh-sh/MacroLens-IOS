//
//  ContentView.swift
//  MacroLens
//
//  Path: MacroLens/ContentView.swift
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

// MARK: - Tab Placeholders
struct HomeTabPlaceholder: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: Constants.UI.spacing16) {
                    Image(systemName: "house.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(Color.primaryGradient)
                    
                    Text("Home View")
                        .font(.headlineLarge)
                        .foregroundColor(.textPrimary)
                    
                    Text("Coming in Day 3")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }
            .navigationTitle("MacroLens")
        }
    }
}

struct ScanTabPlaceholder: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: Constants.UI.spacing16) {
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(Color.primaryGradient)
                    
                    Text("Food Scanner")
                        .font(.headlineLarge)
                        .foregroundColor(.textPrimary)
                    
                    Text("Coming in Day 4")
                        .font(.bodyMedium)
                        .foregroundColor(.textSecondary)
                }
            }
            .navigationTitle("Scan Food")
        }
    }
}

struct ProfileTabPlaceholder: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                VStack(spacing: Constants.UI.spacing24) {
                    // User Info
                    if let user = authViewModel.user {
                        VStack(spacing: Constants.UI.spacing12) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundStyle(Color.primaryGradient)
                            
                            Text(user.fullName) 
                                .font(.headlineLarge)
                                .foregroundColor(.textPrimary)
                            
                            Text(user.email)
                                .font(.bodyMedium)
                                .foregroundColor(.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Logout Button
                    MLButton.destructive(
                        "Log Out",
                        icon: "arrow.right.square"
                    ) {
                        authViewModel.logout()
                    }
                    .padding(.horizontal, Constants.UI.spacing24)
                    .padding(.bottom, Constants.UI.spacing32)
                }
                .padding(.top, 60)
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
