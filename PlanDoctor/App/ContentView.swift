//
//  ContentView.swift
//  PlanDoctor
//
//  Created by azertt on 14/10/2026.
//

//
//  ContentView.swift
//  PlanDoctor
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {

    @State private var currentUser: FirebaseAuth.User?
    @State private var isCheckingAuth = true
    @State private var authListener: AuthStateDidChangeListenerHandle?

    var body: some View {
        ZStack {
            PlantDoctorTheme.background
                .ignoresSafeArea()

            if isCheckingAuth {
                LoadingView()
                    .transition(.opacity)

            } else if let user = currentUser {
                DashboardView(user: user)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing)
                                .combined(with: .opacity),
                            removal: .opacity
                        )
                    )

            } else {
                LoginView()
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .leading)
                                .combined(with: .opacity),
                            removal: .opacity
                        )
                    )
            }
        }
        .animation(.easeInOut(duration: 0.45), value: isCheckingAuth)
        .animation(.easeInOut(duration: 0.45), value: currentUser?.uid)
        .onAppear {
            guard authListener == nil else { return }

            authListener = Auth.auth().addStateDidChangeListener {
                _, user in

                withAnimation(.easeInOut(duration: 0.45)) {
                    currentUser = user
                    isCheckingAuth = false
                }
            }
        }
        .onDisappear {
            if let listener = authListener {
                Auth.auth().removeStateDidChangeListener(listener)
                authListener = nil
            }
        }
    }
}

// MARK: - Loading View

struct LoadingView: View {

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            PlantDoctorTheme.background
                .ignoresSafeArea()

            VStack(spacing: 18) {

                Image(systemName: "leaf.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(PlantDoctorTheme.green)
                    .scaleEffect(isAnimating ? 1.15 : 0.85)
                    .rotationEffect(.degrees(isAnimating ? 12 : -12))

                ProgressView()
                    .tint(PlantDoctorTheme.green)
                    .scaleEffect(1.15)

                Text("Préparation de votre jardin...")
                    .font(.subheadline)
                    .foregroundStyle(PlantDoctorTheme.secondary)
            }
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1)
                    .repeatForever(autoreverses: true)
                ) {
                    isAnimating = true
                }
            }
        }
    }
}
