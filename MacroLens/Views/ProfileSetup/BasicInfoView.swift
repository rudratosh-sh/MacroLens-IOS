//
//  BasicInfoView.swift
//  MacroLens
//
//  Path: MacroLens/Views/ProfileSetup/BasicInfoView.swift
//
//  DEPENDENCIES:
//  - ProfileSetupViewModel
//  - ProfileSetupModels
//  - Design System (Typography, Colors, Constants)
//
//  PURPOSE:
//  - Step 1 of 4-step profile setup
//  - Collect: age, gender, height, weight
//  - Unit toggle (metric/imperial)
//  - Progress indicator (1/4)
//

import SwiftUI

struct BasicInfoView: View {
    @ObservedObject var viewModel: ProfileSetupViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case age
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressBar(currentStep: 1, totalSteps: 4)
                .padding(.horizontal, Constants.UI.spacing24)
                .padding(.top, Constants.UI.spacing16)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: Constants.UI.spacing24) {
                    // Header
                    VStack(alignment: .leading, spacing: Constants.UI.spacing8) {
                        Text("Let's Get to Know You")
                            .h2Bold()
                        
                        Text("Help us personalize your nutrition plan")
                            .mediumTextRegular()
                    }
                    .padding(.top, Constants.UI.spacing32)
                    
                    // Age Input
                    VStack(alignment: .leading, spacing: Constants.UI.spacing12) {
                        Text("Age")
                            .largeTextBold()
                        
                        HStack {
                            TextField("25", value: $viewModel.age, format: .number)
                                .keyboardType(.numberPad)
                                .font(.h3Bold)
                                .foregroundColor(.textPrimary)
                                .multilineTextAlignment(.center)
                                .frame(width: 80)
                                .padding()
                                .background(Color.backgroundSecondary)
                                .cornerRadius(Constants.UI.cornerRadiusMedium)
                                .focused($focusedField, equals: .age)
                            
                            Text("years old")
                                .mediumTextRegular()
                            
                            Spacer()
                        }
                        
                        if let error = viewModel.ageError {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(error)
                                    .font(.captionMedium)
                            }
                            .foregroundColor(.error)
                        }
                    }
                    
                    // Gender Selection
                    VStack(alignment: .leading, spacing: Constants.UI.spacing12) {
                        Text("Gender")
                            .largeTextBold()
                        
                        VStack(spacing: Constants.UI.spacing12) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                GenderOptionButton(
                                    gender: gender,
                                    isSelected: viewModel.gender == gender,
                                    action: {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            viewModel.gender = gender
                                        }
                                    }
                                )
                            }
                        }
                    }
                    
                    // Unit Toggle
                    HStack {
                        Spacer()
                        
                        HStack(spacing: Constants.UI.spacing8) {
                            Text("Metric")
                                .font(.mediumTextSemiBold)
                                .foregroundColor(viewModel.usesMetric ? .primaryStart : .textSecondary)
                            
                            Toggle("", isOn: $viewModel.usesMetric)
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .primaryStart))
                            
                            Text("Imperial")
                                .font(.mediumTextSemiBold)
                                .foregroundColor(!viewModel.usesMetric ? .primaryStart : .textSecondary)
                        }
                    }
                    
                    // Height Input
                    VStack(alignment: .leading, spacing: Constants.UI.spacing12) {
                        Text("Height")
                            .largeTextBold()
                        
                        if viewModel.usesMetric {
                            // Metric: cm
                            HStack(spacing: Constants.UI.spacing12) {
                                TextField("170", value: $viewModel.heightCm, format: .number)
                                    .keyboardType(.decimalPad)
                                    .font(.h3Bold)
                                    .foregroundColor(.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 100)
                                    .padding()
                                    .background(Color.backgroundSecondary)
                                    .cornerRadius(Constants.UI.cornerRadiusMedium)
                                
                                Text("cm")
                                    .mediumTextRegular()
                                
                                Spacer()
                            }
                        } else {
                            // Imperial: ft/in
                            HStack(spacing: Constants.UI.spacing12) {
                                // Feet
                                VStack(spacing: 4) {
                                    TextField("5", value: Binding(
                                        get: { viewModel.heightInFeet() },
                                        set: { viewModel.setHeightFromImperial(feet: $0, inches: viewModel.heightInInches()) }
                                    ), format: .number)
                                        .keyboardType(.numberPad)
                                        .font(.h3Bold)
                                        .foregroundColor(.textPrimary)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 70)
                                        .padding()
                                        .background(Color.backgroundSecondary)
                                        .cornerRadius(Constants.UI.cornerRadiusMedium)
                                    
                                    Text("ft")
                                        .smallTextRegular()
                                }
                                
                                // Inches
                                VStack(spacing: 4) {
                                    TextField("7", value: Binding(
                                        get: { viewModel.heightInInches() },
                                        set: { viewModel.setHeightFromImperial(feet: viewModel.heightInFeet(), inches: $0) }
                                    ), format: .number)
                                        .keyboardType(.numberPad)
                                        .font(.h3Bold)
                                        .foregroundColor(.textPrimary)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 70)
                                        .padding()
                                        .background(Color.backgroundSecondary)
                                        .cornerRadius(Constants.UI.cornerRadiusMedium)
                                    
                                    Text("in")
                                        .smallTextRegular()
                                }
                                
                                Spacer()
                            }
                        }
                        
                        if let error = viewModel.heightError {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(error)
                                    .font(.captionMedium)
                            }
                            .foregroundColor(.error)
                        }
                    }
                    
                    // Weight Input
                    VStack(alignment: .leading, spacing: Constants.UI.spacing12) {
                        Text("Current Weight")
                            .largeTextBold()
                        
                        HStack(spacing: Constants.UI.spacing12) {
                            if viewModel.usesMetric {
                                TextField("70", value: $viewModel.weightKg, format: .number)
                                    .keyboardType(.decimalPad)
                                    .font(.h3Bold)
                                    .foregroundColor(.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 100)
                                    .padding()
                                    .background(Color.backgroundSecondary)
                                    .cornerRadius(Constants.UI.cornerRadiusMedium)
                                
                                Text("kg")
                                    .mediumTextRegular()
                            } else {
                                TextField("154", value: Binding(
                                    get: { viewModel.weightInLbs() },
                                    set: { viewModel.setWeightFromLbs($0) }
                                ), format: .number)
                                    .keyboardType(.decimalPad)
                                    .font(.h3Bold)
                                    .foregroundColor(.textPrimary)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 100)
                                    .padding()
                                    .background(Color.backgroundSecondary)
                                    .cornerRadius(Constants.UI.cornerRadiusMedium)
                                
                                Text("lbs")
                                    .mediumTextRegular()
                            }
                            
                            Spacer()
                        }
                        
                        if let error = viewModel.weightError {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.system(size: 12))
                                Text(error)
                                    .font(.captionMedium)
                            }
                            .foregroundColor(.error)
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, Constants.UI.spacing24)
            }
            
            // Continue Button
            Button(action: {
                viewModel.nextStep()
            }) {
                Text("Continue")
                    .font(.buttonText)
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
            .padding(.horizontal, Constants.UI.spacing24)
            .padding(.bottom, Constants.UI.spacing24)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Step 1 of 4")
                    .mediumTextRegular()
            }
        }
    }
}

// MARK: - Gender Option Button

struct GenderOptionButton: View {
    let gender: Gender
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.UI.spacing16) {
                // Radio Button
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.primaryStart : Color.border, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.primaryStart)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(gender.displayName)
                    .font(.largeTextRegular)
                    .foregroundColor(.textPrimary)
                
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.primaryStart.opacity(0.05) : Color.backgroundSecondary)
            .cornerRadius(Constants.UI.cornerRadiusMedium)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadiusMedium)
                    .stroke(isSelected ? Color.primaryStart : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Progress Bar Component

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: Constants.UI.spacing8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.backgroundSecondary)
                        .frame(height: 4)
                        .cornerRadius(2)
                    
                    // Progress
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [.primaryStart, .primaryEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(currentStep) / CGFloat(totalSteps), height: 4)
                        .cornerRadius(2)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .frame(height: 4)
        }
    }
}

// MARK: - Preview

struct BasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BasicInfoView(viewModel: ProfileSetupViewModel())
        }
    }
}
