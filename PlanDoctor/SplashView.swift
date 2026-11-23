//
//  SplashView.swift
//  PlanDoctor
//
//  Created by azertt on 7/11/2026.
//

import SwiftUI

struct SplashView: View {

    @State private var showMainContent = false

    var body: some View {

        ZStack {

            if showMainContent {

                ContentView()
                    .transition(.opacity)

            } else {

                splashScreen
                    .transition(.opacity)
            }
        }
        .animation(
            .easeInOut(duration: 0.5),
            value: showMainContent
        )
        .task {

            // Safety timeout: do not keep the user
            // on the splash screen indefinitely.
            try? await Task.sleep(
                nanoseconds: 10_000_000_000
            )

            showMainContent = true
        }
    }

    // MARK: - Splash Screen

    private var splashScreen: some View {

        ZStack {

            Color(
                red: 0.95,
                green: 0.97,
                blue: 0.92
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {

                Spacer()

                LottieView(
                    filename: "plantdoctor_animation",
                    onAnimationCompleted: {
                        showMainContent = true
                    }
                )
                .frame(width: 260, height: 260)

                Text("PlantDoctor")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color.green)

                Text("Prenez soin de vos plantes 🌱")
                    .font(.title3)
                    .foregroundStyle(.primary)

                Text(
                    "Détectez les maladies de vos plantes grâce à l'intelligence artificielle."
                )
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)

                Spacer()

                ProgressView()
                    .tint(.green)

                Text("Préparation de votre jardin...")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Preview

#Preview {
    SplashView()
}
