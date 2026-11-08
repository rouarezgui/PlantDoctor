//
//  SplashView.swift
//  PlanDoctor
//
//  Created by azertt on 7/11/2026.
//

import SwiftUI

struct SplashView: View {

    @State private var showLogin = false

    var body: some View {

        Group {
            if showLogin {
                LoginView()
                    .transition(.opacity)
            } else {

                ZStack {
                    Color(red: 0.95, green: 0.97, blue: 0.92)
                        .ignoresSafeArea()

                    VStack(spacing: 20) {

                        Spacer()

                        LottieView(
                            filename: "plantdoctor_animation",
                            onAnimationCompleted: {
                                withAnimation(.easeInOut(duration: 0.4)) {
                                    showLogin = true
                                }
                            }
                        )
                        .frame(width: 260, height: 260)

                        Text("PlantDoctor")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.green)

                        Text("Prenez soin de vos plantes 🌱")
                            .font(.title3)

                        Text("Détectez les maladies de vos plantes grâce à l'intelligence artificielle.")
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text("Préparation de votre jardin...")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}
