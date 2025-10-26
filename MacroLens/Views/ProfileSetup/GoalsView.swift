//
//  GoalsView.swift
//  MacroLens
//
//  Path: MacroLens/Views/ProfileSetup/GoalsView.swift
//
//  DEPENDENCIES:
//  - ProfileSetupViewModel
//  - ProfileSetupModels
//  - Design System (Typography, Colors, Constants)
//
//  PURPOSE:
//  - Step 3 of 4-step profile setup
//  - Select fitness goal: Lose Weight, Maintain, Gain Muscle, Improve Health
//  - Optional target weight (required for lose/gain goals)
//  - Progress indicator (3/4)
//  - Back & Continue navigation
//

import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    @FocusState private var isTargetWeightFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressBar(currentStep: 3, totalSteps: 4)
                .padding(.horizontal, Constants.UI.spacing24)
                .padding(.top, Constants.UI.spacing16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Constants.UI.spacing24) {
                    // Header
                    VStack(alignment: .leading, spacing: Constants.UI.spacing8) {
                        Text("What's Your Goal?")
                            .h2Bold()
                        
                        Text("Choose your primary fitness objective")
                            .mediumTextRegular()
                    }
                    .padding(.top, Constants.UI.spacing32)
                    
                    // Goal Cards
                    VStack(spacing: Constants.UI.spacing16) {
                        ForEach(GoalType.allCases, id: \.self) { goal in
                            GoalCard(
                                goal: goal,
                                isSelected: viewModel.goal == goal,
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.goal = goal
                                        
                                        // Clear target weight if goal doesn't require it
                                        if goal != .loseWeight && goal != .gainMuscle {
                                            viewModel.targetWeightKg = nil
                                            viewModel.targetWeightError = nil
                                        }
                                    }
                                }
                            )
                        }
                    }
                    
                    // Target Weight (conditional)
                    if viewModel.goal == .loseWeight || viewModel.goal == .gainMuscle {
                        VStack(alignment: .leading, spacing: Constants.UI.spacing12) {
                            Text("Target Weight")
                                .largeTextBold()
                            
                            Text("What is your goal weight?")
                                .smallTextRegular()
                            
                            HStack(spacing: Constants.UI.spacing12) {
                                if viewModel.usesMetric {
                                    TextField("65", value: Binding(
                                        get: { viewModel.targetWeightKg ?? 0 },
                                        set: { viewModel.targetWeightKg = $0 }
                                    ), format: .number)
                                        .keyboardType(.decimalPad)
                                        .font(.h3Bold)
                                        .foregroundColor(.textPrimary)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 100)
                                        .padding()
                                        .background(Color.backgroundSecondary)
                                        .cornerRadius(Constants.UI.cornerRadiusMedium)
                                        .focused($isTargetWeightFocused)
                                    
                                    Text("kg")
                                        .mediumTextRegular()
                                } else {
                                    TextField("143", value: Binding(
                                        get: { viewModel.targetWeightInLbs() ?? 0 },
                                        set: { viewModel.setTargetWeightFromLbs($0) }
                                    ), format: .number)
                                        .keyboardType(.decimalPad)
                                        .font(.h3Bold)
                                        .foregroundColor(.textPrimary)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 100)
                                        .padding()
                                        .background(Color.backgroundSecondary)
                                        .cornerRadius(Constants.UI.cornerRadiusMedium)
                                        .focused($isTargetWeightFocused)
                                    
                                    Text("lbs")
                                        .mediumTextRegular()
                                }
                                
                                Spacer()
                            }
                            
                            // Weight Difference Indicator
                            if let targetWeight = viewModel.targetWeightKg {
                                let difference = abs(viewModel.weightKg - targetWeight)
                                let unit = viewModel.usesMetric ? "kg" : "lbs"
                                let displayDiff = viewModel.usesMetric ? difference : difference * 2.20462
                                
                                HStack(spacing: Constants.UI.spacing8) {
                                    Image(systemName: viewModel.goal == .loseWeight ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                        .foregroundColor(.primaryStart)
                                    
                                    Text(String(format: "%.1f %@ to %@", displayDiff, unit, viewModel.goal == .loseWeight ? "lose" : "gain"))
                                        .font(.mediumTextSemiBold)
                                        .foregroundColor(.primaryStart)
                                }
                                .padding(.horizontal, Constants.UI.spacing12)
                                .padding(.vertical, Constants.UI.spacing8)
                                .background(Color.primaryStart.opacity(0.1))
                                .cornerRadius(Constants.UI.cornerRadiusMedium)
                            }
                            
                            if let error = viewModel.targetWeightError {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .font(.system(size: 12))
                                    Text(error)
                                        .font(.captionMedium)
                                }
                                .foregroundColor(.error)
                            }
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
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
                .disabled(!viewModel.canProceed())
                .opacity(viewModel.canProceed() ? 1.0 : 0.5)
            }
            .padding(.horizontal, Constants.UI.spacing24)
            .padding(.bottom, Constants.UI.spacing24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Step 3 of 4")
                    .mediumTextRegular()
            }
        }
    }
}

// MARK: - Goal Card Component

struct GoalCard: View {
    let goal: GoalType
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
                    
                    Image(systemName: goal.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .textSecondary)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: Constants.UI.spacing4) {
                    Text(goal.displayName)
                        .font(.largeTextBold)
                        .foregroundColor(.textPrimary)
                    
                    Text(goal.description)
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
        .buttonStyle(GoalCardButtonStyle())
    }
}

// MARK: - Custom Button Style for Goal Cards

struct GoalCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview

struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GoalsView(viewModel: ProfileSetupViewModel())
        }
    }
}
