//
//  ActivityLevelView.swift
//  MacroLens
//
//  Path: MacroLens/Views/ProfileSetup/ActivityLevelView.swift
//
//  DEPENDENCIES:
//  - ProfileSetupViewModel
//  - ProfileSetupModels
//  - Design System (Typography, Colors, Constants)
//
//  PURPOSE:
//  - Step 2 of 4-step profile setup
//  - Select activity level: Sedentary → Extremely Active
//  - Progress indicator (2/4)
//  - Back & Continue navigation
//

import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressBar(currentStep: 2, totalSteps: 4)
                .padding(.horizontal, Constants.UI.spacing24)
                .padding(.top, Constants.UI.spacing16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Constants.UI.spacing24) {
                    // Header
                    VStack(alignment: .leading, spacing: Constants.UI.spacing8) {
                        Text("Your Activity Level")
                            .h2Bold()
                        
                        Text("Choose the option that best describes your daily activity")
                            .mediumTextRegular()
                    }
                    .padding(.top, Constants.UI.spacing32)
                    
                    // Activity Level Cards
                    VStack(spacing: Constants.UI.spacing16) {
                        ForEach(ActivityLevel.allCases, id: \.self) { level in
                            ActivityLevelCard(
                                level: level,
                                isSelected: viewModel.activityLevel == level,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.activityLevel = level
                                    }
                                }
                            )
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, Constants.UI.spacing24)
            }
            
            // Navigation Buttons
            HStack(spacing: Constants.UI.spacing16) {
                // Back Button
                Button(action: {
                    viewModel.previousStep()
                }) {
                    HStack(spacing: Constants.UI.spacing8) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.buttonSmall)
                    }
                    .foregroundColor(.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.UI.buttonHeightLarge)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(Constants.UI.cornerRadiusLarge)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusLarge)
                            .stroke(Color.border, lineWidth: Constants.UI.borderWidthThin)
                    )
                }
                
                // Continue Button
                Button(action: {
                    viewModel.nextStep()
                }) {
                    HStack(spacing: Constants.UI.spacing8) {
                        Text("Continue")
                            .font(.buttonText)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: Constants.UI.buttonHeightLarge)
                    .background(
                        LinearGradient(
                            colors: [.primaryStart, .primaryEnd],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(Constants.UI.cornerRadiusLarge)
                    .shadow(color: Color.primaryStart.opacity(0.3), radius: 12, x: 0, y: 8)
                }
            }
            .padding(.horizontal, Constants.UI.spacing24)
            .padding(.bottom, Constants.UI.spacing24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Step 2 of 4")
                    .mediumTextRegular()
            }
        }
    }
}

// MARK: - Activity Level Card Component

struct ActivityLevelCard: View {
    let level: ActivityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.UI.spacing16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                            ? LinearGradient(
                                colors: [.primaryStart, .primaryEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.backgroundSecondary, Color.backgroundSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: level.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .textSecondary)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: Constants.UI.spacing4) {
                    Text(level.displayName)
                        .font(.largeTextBold)
                        .foregroundColor(.textPrimary)
                    
                    Text(level.description)
                        .font(.smallTextRegular)
                        .foregroundColor(.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.primaryStart)
                }
            }
            .padding(Constants.UI.spacing16)
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusLarge)
                    .fill(isSelected ? Color.primaryStart.opacity(0.08) : Color.backgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusLarge)
                    .stroke(
                        isSelected
                        ? LinearGradient(
                            colors: [.primaryStart, .primaryEnd],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [Color.clear, Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(
                color: isSelected ? Color.primaryStart.opacity(0.15) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(ActivityCardButtonStyle())
    }
}

// MARK: - Custom Button Style for Activity Cards

struct ActivityCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

struct ActivityLevelView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ActivityLevelView(viewModel: ProfileSetupViewModel())
        }
    }
}
