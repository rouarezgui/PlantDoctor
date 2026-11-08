//
//  LottieView.swift
//  PlanDoctor
//
//  Created by azertt on 7/11/2026.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {

    var filename: String
    var onAnimationCompleted: () -> Void

    func makeUIView(context: Context) -> LottieAnimationView {

        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(filename)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce

        animationView.play { finished in
            if finished {
                DispatchQueue.main.async {
                    onAnimationCompleted()
                }
            }
        }

        return animationView
    }

    func updateUIView(
        _ uiView: LottieAnimationView,
        context: Context
    ) {
    }
}
