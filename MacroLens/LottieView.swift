//
//  LottieView.swift
//  MacroLens
//
//  Path: MacroLens/Views/LottieView.swift
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    
    var animationName: String
    var loopMode: LottieLoopMode = .playOnce // Default to playOnce
    var onComplete: (() -> Void)? = nil      // Optional completion handler

    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        
        animationView.animation = LottieAnimation.named(animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        
        animationView.play { (finished) in
            if finished {
                // Call the completion handler if it exists
                onComplete?()
            }
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // No update needed
    }
}
