//
//  DashboardView.swift
//  PlanDoctor
//
//  Created by azertt on 8/11/2026.
//

import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    let user: FirebaseAuth.User

    var body: some View {
        TabView {
            HomeView(user: user)
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }

            PlantDetectionView()
                .tabItem {
                    Label("Diagnostic", systemImage: "camera.fill")
                }

            HistoryView()
                .tabItem {
                    Label("Historique", systemImage: "clock.fill")
                }

            ProfileView(user: user)
                .tabItem {
                    Label("Profil", systemImage: "person.fill")
                }
        }
        .tint(PlantDoctorTheme.green)
    }
}
