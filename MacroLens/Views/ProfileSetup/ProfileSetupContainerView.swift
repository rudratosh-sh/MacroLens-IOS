//
//  ProfileSetupContainerView.swift
//  MacroLens
//
//  Path: MacroLens/Views/ProfileSetup/ProfileSetupContainerView.swift
//
//  DEPENDENCIES:
//  - ProfileSetupViewModel
//  - BasicInfoView
//  - ActivityLevelView
//  - GoalsView
//  - DietaryPreferencesView
//
//  PURPOSE:
//  - Container for 4-step profile setup flow
//  - Manages navigation between steps with smooth transitions
//  - Entry point after registration
//  - Supports iOS 15+
//

import SwiftUI

struct ProfileSetupContainerView: View {
    @StateObject private var viewModel = ProfileSetupViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var navigateToHome = false
    
    var body: some View {
        if navigateToHome {
            // Navigate to MainTabView after successful profile setup
            MainTabView()
                .transition(.opacity)
        } else if #available(iOS 17.0, *) {
            // iOS 17+ implementation with NavigationStack and new onChange syntax
            NavigationStack {
                contentView
            }
            .onChange(of: viewModel.showSuccess) { _, showSuccess in
                handleSuccess(showSuccess)
            }
        } else if #available(iOS 16.0, *) {
            // iOS 16+ implementation with NavigationStack and old onChange syntax
            NavigationStack {
                contentView
            }
            .onChange(of: viewModel.showSuccess) { showSuccess in
                handleSuccess(showSuccess)
            }
        } else {
            // iOS 15 fallback with NavigationView
            NavigationView {
                contentView
            }
            .navigationViewStyle(.stack)
            .onChange(of: viewModel.showSuccess) { showSuccess in
                handleSuccess(showSuccess)
            }
        }
    }
    
    // MARK: - Content View
    
    private var contentView: some View {
        ZStack {
            // Main content based on current step
            Group {
                switch viewModel.currentStep {
                case 1:
                    BasicInfoView(viewModel: viewModel)
                case 2:
                    ActivityLevelView(viewModel: viewModel)
                case 3:
                    GoalsView(viewModel: viewModel)
                case 4:
                    DietaryPreferencesView(viewModel: viewModel)
                default:
                    BasicInfoView(viewModel: viewModel)
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .id(viewModel.currentStep) // Triggers transition on step change
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Show confirmation dialog before skipping
                    dismiss()
                }) {
                    Text("Skip")
                        .font(.mediumTextSemiBold)
                        .foregroundColor(.textSecondary)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func handleSuccess(_ showSuccess: Bool) {
        if showSuccess {
            // Navigate to home after 2 seconds with smooth transition
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    navigateToHome = true
                }
            }
        }
    }
}

// MARK: - Preview

struct ProfileSetupContainerView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSetupContainerView()
    }
}
