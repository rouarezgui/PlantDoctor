//
//  HomeView.swift
//  PlanDoctor
//
//  Created by azertt on 8/11/2026.
//
import SwiftUI
import FirebaseAuth

struct HomeView: View {
    let user: FirebaseAuth.User

    private var displayName: String {
        let name = user.displayName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let name, !name.isEmpty {
            return name
        }
        return user.email?.components(separatedBy: "@").first ?? "Jardinier"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Bonjour, \(displayName) 👋")
                                .font(.title2.bold())
                                .foregroundStyle(PlantDoctorTheme.text)

                            Text("Prenez soin de votre jardin aujourd'hui.")
                                .font(.subheadline)
                                .foregroundStyle(PlantDoctorTheme.secondary)
                        }

                        Spacer()

                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 43))
                            .foregroundStyle(PlantDoctorTheme.green)
                    }

                    VStack(alignment: .leading, spacing: 15) {
                        Label("PLANTDOCTOR", systemImage: "leaf.fill")
                            .font(.caption.bold())
                            .tracking(2)
                            .foregroundStyle(PlantDoctorTheme.green)

                        Text("Votre jardin mérite le meilleur soin 🌿")
                            .font(.title2.bold())
                            .foregroundStyle(PlantDoctorTheme.text)

                        Text("Surveillez la santé de vos plantes et détectez les maladies grâce à l'intelligence artificielle.")
                            .font(.subheadline)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                            .lineSpacing(4)

                        NavigationLink {
                            PlantDetectionView()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Analyser une plante")
                                Image(systemName: "arrow.right")
                                Spacer()
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .background(PlantDoctorTheme.green)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                    }
                    .padding(20)
                    .background(PlantDoctorTheme.softGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 25))

                    Text("Explorez PlantDoctor")
                        .font(.title3.bold())
                        .foregroundStyle(PlantDoctorTheme.text)

                    NavigationLink {
                        PlantDetectionView()
                    } label: {
                        HomeFeatureCard(
                            icon: "camera.macro",
                            title: "Diagnostic intelligent",
                            subtitle: "Identifiez les maladies de vos plantes."
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        HistoryView()
                    } label: {
                        HomeFeatureCard(
                            icon: "clock.arrow.circlepath",
                            title: "Historique des analyses",
                            subtitle: "Consultez vos précédents diagnostics."
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .background(PlantDoctorTheme.background)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct HomeFeatureCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 25))
                .foregroundStyle(PlantDoctorTheme.green)
                .frame(width: 55, height: 55)
                .background(PlantDoctorTheme.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 15))

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(PlantDoctorTheme.text)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(PlantDoctorTheme.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(PlantDoctorTheme.green)
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(PlantDoctorTheme.border, lineWidth: 1)
        }
    }
}

