//
//  DietaryPreferencesView.swift
//  MacroLens
//
//  Path: MacroLens/Views/ProfileSetup/DietaryPreferencesView.swift
//
//  DEPENDENCIES:
//  - ProfileSetupViewModel
//  - ProfileSetupModels
//  - Design System (Typography, Colors, Constants)
//
//  PURPOSE:
//  - Step 4 of 4-step profile setup
//  - Select dietary restrictions (vegetarian, vegan, etc.)
//  - Select allergies (peanuts, milk, etc.)
//  - Progress indicator (4/4)
//  - Submit profile to backend
//  - Show success state
//

import SwiftUI

struct DietaryPreferencesView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBar(currentStep: 4, totalSteps: 4)
                    .padding(.horizontal, Constants.UI.spacing24)
                    .padding(.top, Constants.UI.spacing16)
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: Constants.UI.spacing32) {
                        // Header
                        VStack(alignment: .leading, spacing: Constants.UI.spacing8) {
                            Text("Dietary Preferences")
                                .h2Bold()
                            
                            Text("Help us personalize your meal recommendations (optional)")
                                .mediumTextRegular()
                        }
                        .padding(.top, Constants.UI.spacing32)
                        
                        // Dietary Restrictions Section
                        VStack(alignment: .leading, spacing: Constants.UI.spacing16) {
                            Text("Dietary Restrictions")
                                .largeTextBold()
                            
                            Text("Select any dietary preferences you follow")
                                .smallTextRegular()
                            
                            if #available(iOS 16.0, *) {
                                FlowLayout(spacing: Constants.UI.spacing12) {
                                    ForEach(DietaryRestriction.allCases, id: \.self) { restriction in
                                        ChipButton(
                                            text: restriction.displayName,
                                            icon: restriction.icon,
                                            isSelected: viewModel.dietaryRestrictions.contains(restriction),
                                            action: {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    if viewModel.dietaryRestrictions.contains(restriction) {
                                                        viewModel.dietaryRestrictions.remove(restriction)
                                                    } else {
                                                        viewModel.dietaryRestrictions.insert(restriction)
                                                    }
                                                }
                                            }
                                        )
                                    }
                                }
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        
                        // Allergies Section
                        VStack(alignment: .leading, spacing: Constants.UI.spacing16) {
                            Text("Allergies")
                                .largeTextBold()
                            
                            Text("Select any food allergies you have")
                                .smallTextRegular()
                            
                            if #available(iOS 16.0, *) {
                                FlowLayout(spacing: Constants.UI.spacing12) {
                                    ForEach(Allergy.allCases, id: \.self) { allergy in
                                        ChipButton(
                                            text: allergy.displayName,
                                            icon: "exclamationmark.triangle.fill",
                                            isSelected: viewModel.allergies.contains(allergy),
                                            action: {
                                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                    if viewModel.allergies.contains(allergy) {
                                                        viewModel.allergies.remove(allergy)
                                                    } else {
                                                        viewModel.allergies.insert(allergy)
                                                    }
                                                }
                                            }
                                        )
                                    }
                                }
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                        
                        // Info Card
                        HStack(spacing: Constants.UI.spacing12) {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.primaryStart)
                            
                            Text("You can skip this step and update preferences later in settings")
                                .font(.smallTextRegular)
                                .foregroundColor(.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(Constants.UI.spacing16)
                        .background(Color.primaryStart.opacity(0.08))
                        .cornerRadius(Constants.UI.cornerRadiusMedium)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, Constants.UI.spacing24)
                }
                
                // Navigation Buttons
                VStack(spacing: Constants.UI.spacing12) {
                    // Submit Button
                    Button(action: {
                        Task {
                            await viewModel.submitProfile()
                        }
                    }) {
                        HStack(spacing: Constants.UI.spacing8) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Setting up your profile...")
                                    .font(.buttonText)
                            } else {
                                Text("Complete Setup")
                                    .font(.buttonText)
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                            }
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
                    .disabled(viewModel.isLoading)
                    
                    // Back Button
                    Button(action: {
                        viewModel.previousStep()
                    }) {
                        Text("Back")
                            .font(.buttonSmall)
                            .foregroundColor(.textSecondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, Constants.UI.spacing24)
                .padding(.bottom, Constants.UI.spacing24)
            }
            
            // Success Overlay
            if viewModel.showSuccess {
                SuccessOverlay(profile: viewModel.calculatedProfile)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Step 4 of 4")
                    .mediumTextRegular()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
}

// MARK: - Chip Button Component

struct ChipButton: View {
    let text: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.UI.spacing8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                
                Text(text)
                    .font(.mediumTextSemiBold)
            }
            .foregroundColor(isSelected ? .white : .textPrimary)
            .padding(.horizontal, Constants.UI.spacing16)
            .padding(.vertical, Constants.UI.spacing10)
            .background(
                isSelected
                ? LinearGradient(
                    colors: [.primaryStart, .primaryEnd],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                : LinearGradient(
                    colors: [Color.backgroundSecondary, Color.backgroundSecondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(Constants.UI.cornerRadiusLarge)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusLarge)
                    .stroke(isSelected ? Color.clear : Color.border, lineWidth: Constants.UI.borderWidthThin)
            )
            .shadow(
                color: isSelected ? Color.primaryStart.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(ChipButtonStyle())
    }
}

// MARK: - Chip Button Style

struct ChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Flow Layout (Wrapping Layout)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    @available(iOS 16.0, *)
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    @available(iOS 16.0, *)
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    @available(iOS 16.0, *)
    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var maxHeight: CGFloat = 0
        var totalHeight: CGFloat = 0
        
        let width = proposal.width ?? 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if currentX + size.width > width && currentX > 0 {
                currentX = 0
                currentY += maxHeight + spacing
                totalHeight = currentY
                maxHeight = 0
            }
            
            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            maxHeight = max(maxHeight, size.height)
        }
        
        totalHeight += maxHeight
        
        return (CGSize(width: width, height: totalHeight), positions)
    }
}

// MARK: - Success Overlay

struct SuccessOverlay: View {
    let profile: UserProfile?
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: Constants.UI.spacing24) {
                // Success Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.primaryStart, .primaryEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color.primaryStart.opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(scale)
                
                VStack(spacing: Constants.UI.spacing12) {
                    Text("Profile Complete!")
                        .h2Bold()
                        .foregroundColor(.textPrimary)
                    
                    if let profile = profile {
                        VStack(spacing: Constants.UI.spacing8) {
                            Text("Your personalized nutrition plan:")
                                .mediumTextRegular()
                            
                            // Macro Summary
                            VStack(spacing: Constants.UI.spacing8) {
                                MacroRow(label: "Daily Calories", value: "\(profile.dailyCalories) kcal")
                                MacroRow(label: "Protein", value: "\(profile.dailyProtein)g")
                                MacroRow(label: "Carbs", value: "\(profile.dailyCarbs)g")
                                MacroRow(label: "Fats", value: "\(profile.dailyFats)g")
                            }
                            .padding(Constants.UI.spacing16)
                            .background(Color.backgroundSecondary)
                            .cornerRadius(Constants.UI.cornerRadiusMedium)
                        }
                    }
                    
                    Text("Redirecting to home...")
                        .smallTextRegular()
                        .foregroundColor(.textSecondary)
                }
                .opacity(opacity)
            }
            .padding(Constants.UI.spacing32)
            .background(Color.white)
            .cornerRadius(Constants.UI.cornerRadiusXLarge)
            .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 10)
            .padding(Constants.UI.spacing32)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.2)) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - Macro Row Component

struct MacroRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.mediumTextRegular)
                .foregroundColor(.textSecondary)
            
            Spacer()
            
            Text(value)
                .font(.mediumTextBold)
                .foregroundColor(.primaryStart)
        }
    }
}

// MARK: - Preview

struct DietaryPreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DietaryPreferencesView(viewModel: ProfileSetupViewModel())
        }
    }
}
