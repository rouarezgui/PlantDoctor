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

    func makeCoordinator() -> Coordinator {
        Coordinator(onAnimationCompleted: onAnimationCompleted)
    }

    func makeUIView(context: Context) -> LottieAnimationView {

        let animationView = LottieAnimationView()

        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce

        if let animation = LottieAnimation.named(filename) {

            animationView.animation = animation

            animationView.play { finished in

                guard finished else { return }

                DispatchQueue.main.async {
                    context.coordinator.animationDidComplete()
                }
            }

        } else {

            // If the animation file is missing, continue to the app.
            DispatchQueue.main.async {
                context.coordinator.animationDidComplete()
            }
        }

        return animationView
    }

    func updateUIView(
        _ uiView: LottieAnimationView,
        context: Context
    ) {
        context.coordinator.onAnimationCompleted = onAnimationCompleted
    }

    // MARK: - Coordinator

    class Coordinator {

        var onAnimationCompleted: () -> Void
        private var hasCompleted = false

        init(onAnimationCompleted: @escaping () -> Void) {
            self.onAnimationCompleted = onAnimationCompleted
        }

        func animationDidComplete() {

            guard !hasCompleted else { return }

            hasCompleted = true
            onAnimationCompleted()
        }
    }
}
