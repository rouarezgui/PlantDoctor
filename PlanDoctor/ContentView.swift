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
        Group {
            if isCheckingAuth {
                LoadingView()
            } else if let user = currentUser {
                DashboardView(user: user)
            } else {
                LoginView()
            }
        }
        .onAppear {
            guard authListener == nil else { return }

            authListener = Auth.auth().addStateDidChangeListener {
                _, user in

                currentUser = user
                isCheckingAuth = false
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

struct LoadingView: View {
    var body: some View {
        ZStack {
            PlantDoctorTheme.background.ignoresSafeArea()

            VStack(spacing: 15) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 45))
                    .foregroundStyle(PlantDoctorTheme.green)

                ProgressView()
                    .tint(PlantDoctorTheme.green)

                Text("Préparation de votre jardin...")
                    .font(.subheadline)
                    .foregroundStyle(PlantDoctorTheme.secondary)
            }
        }
    }
}
