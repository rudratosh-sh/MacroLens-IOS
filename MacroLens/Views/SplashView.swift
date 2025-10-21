//
//  SplashView.swift
//  MacroLens
//
//  Path: MacroLens/Views/SplashView.swift
//

import SwiftUI

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
                    Spacer() // Remove fixed height to let it expand dynamically
                    
                    // Logo
                    Image("newlogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                    
                    Spacer() // Let this expand to push the button to the bottom
                    
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isActive = true
                    }
                }
            }
        }
    }
}
