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
                    Label("tab.home", systemImage: "house.fill")
                }

            PlantDetectionView()
                .tabItem {
                    Label("tab.diagnosis", systemImage: "camera.fill")
                }

            HistoryView()
                .tabItem {
                    Label("tab.history", systemImage: "clock.fill")
                }

            ProfileView(user: user)
                .tabItem {
                    Label("tab.profile", systemImage: "person.fill")
                }

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gearshape.fill")
                }
        }
        .tint(PlantDoctorTheme.green)
    }
}
