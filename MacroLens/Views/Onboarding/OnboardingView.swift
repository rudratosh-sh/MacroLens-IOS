//
//  OnboardingView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Onboarding/OnboardingView.swift
//

import SwiftUI
import Lottie

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    
    var body: some View {
        if isOnboardingComplete {
            // ✅ FUNCTIONALITY: Navigates to LoginView
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
                
                // ✅ FUNCTIONALITY: Added "Skip" button
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            completeOnboarding()
                        }) {
                            Text("Skip")
                                .font(.custom("Poppins-Medium", size: 16))
                                .foregroundColor(.textSecondary) // You may need to adjust this color if it's not in your assets
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                    
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        // ✅ VISUAL: Kept original button from first file
                        CustomNextButton(currentPage: currentPage, totalPages: 4) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if currentPage < 3 {
                                    currentPage += 1
                                } else {
                                    // ✅ FUNCTIONALITY: Call helper function
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
    
    /// ✅ FUNCTIONALITY: Added helper function from new file
    /// Complete onboarding and store flag
    private func completeOnboarding() {
        // Store onboarding completion in UserDefaults
        UserDefaultsManager.shared.completeOnboarding()
        
        Config.Logging.log("Onboarding completed - flag stored", level: .info)
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isOnboardingComplete = true
        }
    }
}

// MARK: - Page 1
// ✅ VISUAL: Kept original Page 1
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

// MARK: - Custom Next Button
// ✅ VISUAL: Kept original CustomNextButton and its helpers
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
                        startPoint: .bottomTrailing,
                        endPoint: .topLeading
                    )
                )
                .frame(width: 50, height: 50)
            
            ArrowShape()
                .stroke(Color.white, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .frame(width: 10, height: 20)
                .position(x: 30.5, y: 31)
        }
        .frame(width: 61, height: 61)
        .contentShape(Circle())
        .onTapGesture(perform: action)
    }
}

struct ProgressArc: Shape {
    var progress: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2 - 1
        let startAngle = Angle(degrees: -90)
        let endAngle = Angle(degrees: -90 + max(1, Double(progress) * 360))
        
        path.addArc(center: center,
                    radius: radius - 0.25,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        
        return path
    }
}

struct ArrowShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let scaleX = rect.width / 5.25
        let scaleY = rect.height / 10.5
        
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: scaleY * 5.25))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}

// MARK: - Page 2
// ✅ VISUAL: Kept original Page 2
struct OnboardingPage2: View {
    var body: some View {
        ZStack {
            GeometryReader { geo in
                Path { path in
                    let width = geo.size.width
                    let scale = width / 375
                    
                    path.move(to: CGPoint(x: 0, y: -40 * scale))
                    path.addLine(to: CGPoint(x: width, y: -40 * scale))
                    path.addLine(to: CGPoint(x: width, y: 151.957 * scale))
                    
                    path.addCurve(to: CGPoint(x: 291.067 * scale, y: 218.742 * scale),
                                  control1: CGPoint(x: 346.733 * scale, y: 151.957 * scale),
                                  control2: CGPoint(x: 353.667 * scale, y: 218.742 * scale))
                    
                    path.addCurve(to: CGPoint(x: 122.033 * scale, y: 90.4374 * scale),
                                  control1: CGPoint(x: 228.467 * scale, y: 218.742 * scale),
                                  control2: CGPoint(x: 184.633 * scale, y: 90.4374 * scale))
                    
                    path.addCurve(to: CGPoint(x: 0, y: 214.043 * scale),
                                  control1: CGPoint(x: 59.4333 * scale, y: 90.4374 * scale),
                                  control2: CGPoint(x: 0, y: 214.043 * scale))
                    
                    path.closeSubpath()
                }
                .fill(Color.primaryLinear)
                .frame(width: geo.size.width, height: geo.size.height)
                .edgesIgnoringSafeArea(.all)
            }
            
            Image("OnboardingIllustration2")
                .resizable()
                .scaledToFit()
                .frame(width: 268, height: 323)
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
// ✅ VISUAL: Kept original Page 3 (with Lottie animation)
struct OnboardingPage3: View {
    var body: some View {
        ZStack {
            // Background gradient with corrected SVG path
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    let scale = width / 375
                    
                    // Start at bottom-left
                    path.move(to: CGPoint(x: 0, y: 208.102 * scale))
                    
                    // First curve
                    path.addCurve(to: CGPoint(x: 45.1 * scale, y: 293.939 * scale),
                                  control1: CGPoint(x: 0 * scale, y: 208.102 * scale),
                                  control2: CGPoint(x: 22.4 * scale, y: 211.641 * scale))
                    
                    // Second curve
                    path.addCurve(to: CGPoint(x: 212.967 * scale, y: 437 * scale),
                                  control1: CGPoint(x: 67.8 * scale, y: 376.236 * scale),
                                  control2: CGPoint(x: 130.8 * scale, y: 437 * scale))
                    
                    // Third curve
                    path.addCurve(to: CGPoint(x: 375 * scale, y: 248.065 * scale),
                                  control1: CGPoint(x: 295.133 * scale, y: 437 * scale),
                                  control2: CGPoint(x: 375 * scale, y: 322.517 * scale))
                    
                    // Connect to top and close
                    path.addLine(to: CGPoint(x: 375 * scale, y: -2 * scale))
                    path.addLine(to: CGPoint(x: 0, y: -2 * scale))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#007B83"), Color(hex: "#00BFA6")]),
                        startPoint: UnitPoint(x: 1, y: 1),
                        endPoint: UnitPoint(x: -0.335, y: 0.924)
                    )
                )
            }
            .edgesIgnoringSafeArea(.top)
            
            Image("OnboardingCharacterWithoutBowl3")
                .resizable()
                .scaledToFit()
                .frame(width: 308, height: 351)
                .position(x: UIScreen.main.bounds.width / 2 + 15 , y: 238)
            
            LottieView(animationName: "saladBowl", loopMode: .playOnce)
                .frame(width: 118.25, height: 69.26)
                .position(x: UIScreen.main.bounds.width / 2 + 72 , y: 287)
            
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
// ✅ VISUAL: Kept original Page 4
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
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .onAppear {
                            isAnimating = true
                        }
                    
                    Spacer()
                        .frame(height: 60)
                    
                    // Text content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Improve Your Health")
                            .h2Bold(color: .blackPrimary)
                            .padding(.horizontal, 40)
                            .padding(.bottom, 8)
                        
                        Text("Track your fitness journey with us, we will help you reach your goals everyday with personalized insights")
                            .mediumTextRegular(color: .gray1)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                        .frame(height: 180)
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}


struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
