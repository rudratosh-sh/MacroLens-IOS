//
//  SplashView.swift
//  MacroLens
//
//  Path: MacroLens/Views/SplashView.swift
//

import SwiftUI
import Lottie // <-- 1. Import Lottie

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            OnboardingView()
        } else {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    // 2. Replace the Image with your new LottieView
                    LottieView(animationName: "logo", loopMode: .playOnce) {
                        // This code now runs when the animation finishes
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isActive = true
                        }
                    }
                    .frame(width: 250, height: 250)
                    
                    Spacer()
                    
                    // Get Started Button
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isActive = true
                        }
                    }) {
                        Text("Get Started")
                            .font(.custom("Poppins-SemiBold", size: 18))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(hex: "007B83"),
                                        Color(hex: "00BFA6")
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(30)
                            .shadow(color: Color(hex: "007B83").opacity(0.25), radius: 12, x: 0, y: 8)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 60)
                }
            }
            .edgesIgnoringSafeArea(.all)
            // 3. You don't need the .onAppear timer anymore!
            // The LottieView will set 'isActive' to true when it finishes.
        }
    }
}


