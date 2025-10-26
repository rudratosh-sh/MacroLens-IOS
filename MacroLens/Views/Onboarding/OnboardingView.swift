//
//  OnboardingView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Onboarding/OnboardingView.swift
//
//  DEPENDENCIES:
//  - LoginView.swift
//  - UserDefaultsManager.swift (for storing completion flag)
//  - Lottie framework
//  - Custom components (CustomNextButton, ProgressArc)
//
//  PURPOSE:
//  - Show 4-page onboarding flow for first-time users
//  - Store completion flag in UserDefaults
//  - Navigate to LoginView after completion
//

import SwiftUI
import Lottie

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    
    var body: some View {
        if isOnboardingComplete {
            LoginView()
        } else {
            ZStack {
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)
                    
                    OnboardingPage2()
                        .tag(1)
                    
                    OnboardingPage3()
                        .tag(2)
                    
                    OnboardingPage4()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.all)
                
                // Skip Button (Top-Right)
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.custom("Poppins-Medium", size: 16))
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                    
                    Spacer()
                }
                
                // Next Button (Bottom-Right)
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        CustomNextButton(currentPage: currentPage, totalPages: 4) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if currentPage < 3 {
                                    currentPage += 1
                                } else {
                                    completeOnboarding()
                                }
                            }
                        }
                        .padding(.trailing, 30)
                        .padding(.bottom, 50)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Complete onboarding and store flag
    private func completeOnboarding() {
        // ✅ ADDED: Store onboarding completion in UserDefaults
        UserDefaultsManager.shared.completeOnboarding()
        
        Config.Logging.log("Onboarding completed - flag stored", level: .info)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isOnboardingComplete = true
        }
    }
}

// MARK: - Page 1
struct OnboardingPage1: View {
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Path { path in
                    let width = geo.size.width
                    let height = geo.size.height
                    let scale = width / 375
                    
                    path.move(to: CGPoint(x: width, y: 251.018 * scale))
                    path.addCurve(to: CGPoint(x: 0, y: 355.137 * scale),
                                  control1: CGPoint(x: 302.933 * scale, y: 400.393 * scale),
                                  control2: CGPoint(x: 191.1 * scale, y: 405.53 * scale))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.closeSubpath()
                }
                .fill(Color.primaryLinear)
                .frame(width: geo.size.width, height: geo.size.height)
                .edgesIgnoringSafeArea(.all)
            }
            
            Image("OnboardingIllustration1")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 300)
                .position(x: UIScreen.main.bounds.width / 2, y: 200)
            
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                Text("Track Your Goal")
                    .h2Bold(color: .blackPrimary)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 8)
                
                Text("Don't worry if you have trouble determining your goals, We can help you determine your goals and track your goals")
                    .mediumTextRegular(color: .gray1)
                    .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 180)
            }
        }
    }
}

// MARK: - Page 2
struct OnboardingPage2: View {
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Path { path in
                    let width = geo.size.width
                    let scale = width / 375
                    
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 325.699 * scale))
                    
                    path.addCurve(to: CGPoint(x: 245.333 * scale, y: 368.257 * scale),
                                  control1: CGPoint(x: width, y: 325.699 * scale),
                                  control2: CGPoint(x: 297.8 * scale, y: 368.257 * scale))
                    
                    path.addCurve(to: CGPoint(x: 0, y: 109.477 * scale),
                                  control1: CGPoint(x: 134.467 * scale, y: 368.257 * scale),
                                  control2: CGPoint(x: 29 * scale, y: 124.706 * scale))
                    
                    path.closeSubpath()
                }
                .fill(Color.primaryLinear)
                .frame(width: geo.size.width, height: geo.size.height)
                .edgesIgnoringSafeArea(.all)
            }
            
            Image("OnboardingIllustration2")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 300)
                .position(x: UIScreen.main.bounds.width / 2, y: 200)
            
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                Text("Get Burn")
                    .h2Bold(color: .blackPrimary)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 8)
                
                Text("Let's keep burning, to achive yours goals, it hurts only temporarily, if you give up now you will be in pain forever")
                    .mediumTextRegular(color: .gray1)
                    .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 180)
            }
        }
    }
}

// MARK: - Page 3
struct OnboardingPage3: View {
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Path { path in
                    let width = geo.size.width
                    let scale = width / 375
                    
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 0))
                    path.addLine(to: CGPoint(x: width, y: 280 * scale))
                    
                    path.addCurve(to: CGPoint(x: 0, y: 387.257 * scale),
                                  control1: CGPoint(x: width, y: 322 * scale),
                                  control2: CGPoint(x: 52.7 * scale, y: 387.257 * scale))
                    
                    path.addCurve(to: CGPoint(x: 0, y: 109.477 * scale),
                                  control1: CGPoint(x: -52.7 * scale, y: 387.257 * scale),
                                  control2: CGPoint(x: 0, y: 184 * scale))
                    
                    path.closeSubpath()
                }
                .fill(Color.primaryLinear)
                .frame(width: geo.size.width, height: geo.size.height)
                .edgesIgnoringSafeArea(.all)
            }
            
            Image("OnboardingIllustration3")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 300)
                .position(x: UIScreen.main.bounds.width / 2, y: 200)
            
            VStack(alignment: .leading, spacing: 16) {
                Spacer()
                
                Text("Eat Well")
                    .h2Bold(color: .blackPrimary)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 8)
                
                Text("Let's start a healthy lifestyle with us, we can determine your diet every day. healthy eating is fun")
                    .mediumTextRegular(color: .gray1)
                    .padding(.horizontal, 40)
                
                Spacer()
                    .frame(height: 180)
            }
        }
    }
}

// MARK: - Page 4 (Final CTA Page)
struct OnboardingPage4: View {
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient with SVG path
                Path { path in
                    let width = geometry.size.width
                    let scale = width / 375
                    
                    path.move(to: CGPoint(x: 0, y: -27 * scale))
                    path.addLine(to: CGPoint(x: width, y: -27 * scale))
                    path.addLine(to: CGPoint(x: width, y: 303.599 * scale))
                    
                    path.addCurve(to: CGPoint(x: 294.733 * scale, y: 346.158 * scale),
                                  control1: CGPoint(x: width, y: 303.599 * scale),
                                  control2: CGPoint(x: 350.3 * scale, y: 346.158 * scale))
                    
                    path.addCurve(to: CGPoint(x: 42.7333 * scale, y: 87.378 * scale),
                                  control1: CGPoint(x: 186.333 * scale, y: 346.158 * scale),
                                  control2: CGPoint(x: 83.0333 * scale, y: 102.606 * scale))
                    
                    path.addCurve(to: CGPoint(x: 0, y: 118.599 * scale),
                                  control1: CGPoint(x: 13.8333 * scale, y: 76.4389 * scale),
                                  control2: CGPoint(x: 0, y: 118.599 * scale))
                    
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.primaryStart, Color.primaryEnd]),
                        startPoint: UnitPoint(x: 1, y: 1),
                        endPoint: UnitPoint(x: -0.335, y: 0.924)
                    )
                )
                .edgesIgnoringSafeArea(.top)
                
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 80)
                    
                    // Character illustration with floating animation
                    Image("OnboardingIllustration4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 340)
                        .offset(y: isAnimating ? -10 : 10)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                isAnimating = true
                            }
                        }
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Text content
                    VStack(spacing: 20) {
                        Text("Welcome, MacroLens")
                            .font(.custom("Poppins-SemiBold", size: 24))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        Text("You are all set now, let's reach your\ngoals together with us")
                            .font(.custom("Poppins-Regular", size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            }
        }
    }
}

// MARK: - Custom Next Button
struct CustomNextButton: View {
    let currentPage: Int
    let totalPages: Int
    let action: () -> Void
    
    var progress: CGFloat {
        return CGFloat(currentPage + 1) / CGFloat(totalPages)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "F7F8F8"), lineWidth: 0.5)
                .frame(width: 61, height: 61)
            
            ProgressArc(progress: progress)
                .stroke(
                    LinearGradient(
                        colors: [Color.primaryStart, Color.primaryEnd],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .frame(width: 61, height: 61)
                .animation(.easeInOut(duration: 0.5), value: currentPage)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.primaryStart, Color.primaryEnd],
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .frame(width: 54, height: 54)
                .shadow(color: Color.primaryStart.opacity(0.25), radius: 22, x: 0, y: 4)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
        }
        .onTapGesture {
            action()
        }
    }
}

// MARK: - Progress Arc Shape
struct ProgressArc: Shape {
    var progress: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let startAngle = Angle(degrees: -90)
        let endAngle = Angle(degrees: -90 + (360 * Double(progress)))
        
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        
        return path
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
