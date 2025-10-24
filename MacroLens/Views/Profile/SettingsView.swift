//
//  SettingsView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Profile/SettingsView.swift
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showLogoutConfirmation = false
    @State private var isLoggingOut = false
    
    var body: some View {
        NavigationView {
            List {
                // Profile Section
                Section {
                    if let user = authViewModel.user {
                        HStack(spacing: Constants.UI.spacing16) {
                            // Avatar
                            Circle()
                                .fill(LinearGradient(
                                    colors: [.primaryStart, .primaryEnd],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(user.initials)
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.fullName)
                                    .font(.headline)
                                    .foregroundColor(.textPrimary)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.textSecondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, Constants.UI.spacing8)
                    }
                }
                
                // Account Settings
                Section("Account") {
                    NavigationLink(destination: EditProfileView()) {
                        SettingsRow(
                            icon: "person.fill",
                            title: "Edit Profile",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: GoalsSettingsView()) {
                        SettingsRow(
                            icon: "target",
                            title: "Goals & Targets",
                            color: .green
                        )
                    }
                }
                
                // Preferences
                Section("Preferences") {
                    NavigationLink(destination: NotificationSettingsView()) {
                        SettingsRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            color: .orange
                        )
                    }
                    
                    NavigationLink(destination: UnitsSettingsView()) {
                        SettingsRow(
                            icon: "ruler.fill",
                            title: "Units & Measurements",
                            color: .purple
                        )
                    }
                }
                
                // Data & Privacy
                Section("Data & Privacy") {
                    Button(action: {
                        // TODO: Export data
                    }) {
                        SettingsRow(
                            icon: "square.and.arrow.up.fill",
                            title: "Export Data",
                            color: .blue
                        )
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        SettingsRow(
                            icon: "hand.raised.fill",
                            title: "Privacy Policy",
                            color: .gray
                        )
                    }
                    
                    NavigationLink(destination: TermsOfServiceView()) {
                        SettingsRow(
                            icon: "doc.text.fill",
                            title: "Terms of Service",
                            color: .gray
                        )
                    }
                }
                
                // Support
                Section("Support") {
                    Button(action: {
                        // TODO: Open help center
                    }) {
                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "Help Center",
                            color: .blue
                        )
                    }
                    
                    Button(action: {
                        // TODO: Send feedback
                    }) {
                        SettingsRow(
                            icon: "envelope.fill",
                            title: "Send Feedback",
                            color: .blue
                        )
                    }
                    
                    Button(action: {
                        // TODO: Rate app
                    }) {
                        SettingsRow(
                            icon: "star.fill",
                            title: "Rate MacroLens",
                            color: .yellow
                        )
                    }
                }
                
                // About
                Section("About") {
                    HStack {
                        Text("Version")
                            .foregroundColor(.textPrimary)
                        Spacer()
                        Text(Config.App.version)
                            .foregroundColor(.textSecondary)
                    }
                }
                
                // Logout Section
                Section {
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            if isLoggingOut {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .error))
                            } else {
                                Text("Log Out")
                                    .font(.headline)
                                    .foregroundColor(.error)
                            }
                            Spacer()
                        }
                        .padding(.vertical, Constants.UI.spacing8)
                    }
                    .disabled(isLoggingOut)
                    
                    Button(action: {
                        // TODO: Delete account
                    }) {
                        HStack {
                            Spacer()
                            Text("Delete Account")
                                .font(.subheadline)
                                .foregroundColor(.error.opacity(0.7))
                            Spacer()
                        }
                        .padding(.vertical, Constants.UI.spacing4)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    performLogout()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You'll need to log in again to access your account.")
            }
            .alert("Logout Failed", isPresented: .constant(authViewModel.errorMessage != nil && isLoggingOut)) {
                Button("OK") {
                    authViewModel.clearError()
                    isLoggingOut = false
                }
            } message: {
                Text(authViewModel.errorMessage ?? "An error occurred while logging out.")
            }
        }
    }
    
    // MARK: - Logout Action
    
    private func performLogout() {
        isLoggingOut = true
        
        Task {
            await MainActor.run {
                authViewModel.logout()
                isLoggingOut = false
            }
        }
    }
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    var subtitle: String?
    
    var body: some View {
        HStack(spacing: Constants.UI.spacing12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Placeholder Views
struct EditProfileView: View {
    var body: some View {
        Text("Edit Profile - Coming Soon")
            .navigationTitle("Edit Profile")
    }
}

struct GoalsSettingsView: View {
    var body: some View {
        Text("Goals Settings - Coming Soon")
            .navigationTitle("Goals & Targets")
    }
}

struct NotificationSettingsView: View {
    var body: some View {
        Text("Notification Settings - Coming Soon")
            .navigationTitle("Notifications")
    }
}

struct UnitsSettingsView: View {
    var body: some View {
        Text("Units Settings - Coming Soon")
            .navigationTitle("Units & Measurements")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy - Coming Soon")
            .navigationTitle("Privacy Policy")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        Text("Terms of Service - Coming Soon")
            .navigationTitle("Terms of Service")
    }
}

// MARK: - User Extension for Initials
extension User {
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.count > 1 ? components.last?.first?.uppercased() ?? "" : ""
        return firstInitial + lastInitial
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
