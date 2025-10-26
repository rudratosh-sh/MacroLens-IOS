//
//  SplashView.swift
//  MacroLens
//
//  Path: MacroLens/Views/SplashView.swift
//
//  DEPENDENCIES:
//  - AuthenticationManager.swift (for auth state)
//  - UserDefaultsManager.swift (for onboarding flag)
//  - LoginView.swift
//  - OnboardingView.swift
//  - MainTabView.swift
//  - ProfileSetupContainerView.swift (✅ ADDED)
//  - Lottie framework
//
//  PURPOSE:
//  - Initial splash screen with logo animation
//  - Smart routing based on:
//    1. First launch → OnboardingView
//    2. Not authenticated → LoginView
//    3. Authenticated but profile incomplete → ProfileSetupContainerView (✅ ADDED)
//    4. Authenticated → MainTabView (Home)
//

import SwiftUI
import Lottie

struct SplashView: View {
    @StateObject private var authManager = AuthenticationManager.shared
    @State private var isChecking = true
    @State private var destination: Destination?
    
    enum Destination {
        case onboarding
        case login
        case profileSetup  // ✅ ADDED
        case home
    }
    
    var body: some View {
        Group {
            if isChecking {
                // Splash Screen with Animation
                splashContent
            } else {
                // Navigate based on destination
                destinationView
            }
        }
    }
    
    // MARK: - Splash Content
    
    private var splashContent: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo Animation
                LottieView(animationName: "logo", loopMode: .playOnce) {
                    // Animation finished - check destination
                    checkDestination()
                }
                .frame(width: 250, height: 250)
                
                Spacer()
                
                // Get Started Button (optional - only if checking takes time)
                if authManager.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "007B83")))
                        .padding(.bottom, 60)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Start checking immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                checkDestination()
            }
        }
    }
    
    // MARK: - Destination View
    
    @ViewBuilder
    private var destinationView: some View {
        switch destination {
        case .onboarding:
            OnboardingView()
                .transition(.opacity)
        case .login:
            LoginView()
                .transition(.opacity)
        case .profileSetup:  // ✅ ADDED
            ProfileSetupContainerView()
                .transition(.opacity)
        case .home:
            MainTabView()
                .transition(.opacity)
        case .none:
            EmptyView()
        }
    }
    
    // MARK: - Routing Logic
    
    private func checkDestination() {
        // Priority 1: Check if first launch (onboarding not completed)
        if !UserDefaultsManager.shared.hasCompletedOnboarding {
            Config.Logging.log("First launch detected - showing onboarding", level: .info)
            withAnimation(.easeInOut(duration: 0.3)) {
                destination = .onboarding
                isChecking = false
            }
            return
        }
        
        // Priority 2: Check authentication state
        if authManager.isAuthenticated && authManager.currentUser != nil {
            // ✅ ADDED: Priority 3 - Check profile setup completion
            if !UserDefaultsManager.shared.hasCompletedProfileSetup {
                Config.Logging.log("Profile setup incomplete - resuming at step \(UserDefaultsManager.shared.currentProfileStep)", level: .info)
                withAnimation(.easeInOut(duration: 0.3)) {
                    destination = .profileSetup
                    isChecking = false
                }
                return
            }
            
            Config.Logging.log("User authenticated - navigating to home", level: .info)
            withAnimation(.easeInOut(duration: 0.3)) {
                destination = .home
                isChecking = false
            }
        } else {
            Config.Logging.log("User not authenticated - showing login", level: .info)
            withAnimation(.easeInOut(duration: 0.3)) {
                destination = .login
                isChecking = false
            }
        }
    }
}

// MARK: - Preview
struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
