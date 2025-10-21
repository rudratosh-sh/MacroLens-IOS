//
//  OnboardingView.swift
//  MacroLens
//
//  Path: MacroLens/Views/Onboarding/OnboardingView.swift
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isOnboardingComplete = false
    
    var body: some View {
        if isOnboardingComplete {
            ContentView()
        } else {
            ZStack {
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)
                    
                    OnboardingPage2()
                        .tag(1)
                    
                    OnboardingPage3()
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        CustomNextButton(currentPage: currentPage, totalPages: 3) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                if currentPage < 2 {
                                    currentPage += 1
                                } else {
                                    isOnboardingComplete = true
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
                
                Text("Let’s keep burning, to achive yours goals, it hurts only temporarily, if you give up now you will be in pain forever")
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
            Color.backgroundSecondary
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Circle()
                    .fill(Color.secondaryGradient)
                    .frame(width: 300, height: 300)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                    )
                    .padding(.top, 120)
                
                Spacer()
                    .frame(height: 40)
                
                Text("Eat Well")
                    .font(.h2Bold)
                    .foregroundColor(.blackPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Text("Let's start a healthy lifestyle with us. We can determine your diet every day. Healthy eating is fun")
                    .font(.mediumTextRegular)
                    .foregroundColor(.gray1)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                    .padding(.top, 16)
                
                Spacer()
            }
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
