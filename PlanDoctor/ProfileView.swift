//
//  ProfileView.swift
//  PlanDoctor
//
//  Created by azertt on 8/11/2026.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    let user: FirebaseAuth.User

    @State private var showLogoutAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(PlantDoctorTheme.green)

                VStack(spacing: 8) {
                    Text(user.displayName ?? "Utilisateur PlantDoctor")
                        .font(.title2.bold())
                        .foregroundStyle(PlantDoctorTheme.text)

                    Text(user.email ?? "Aucun email")
                        .font(.subheadline)
                        .foregroundStyle(PlantDoctorTheme.secondary)
                }

                VStack(alignment: .leading, spacing: 15) {
                    Label("Informations du compte", systemImage: "person")
                        .font(.headline)

                    Divider()

                    Text("Adresse email")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)

                    Text(user.email ?? "Non disponible")
                        .font(.body)
                        .foregroundStyle(PlantDoctorTheme.text)

                    Divider()

                    Text("Identifiant utilisateur")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)

                    Text(user.uid)
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.text)
                        .textSelection(.enabled)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Button(role: .destructive) {
                    showLogoutAlert = true
                } label: {
                    Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(Color.red.opacity(0.85))
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }

                Spacer()
            }
            .padding()
            .background(PlantDoctorTheme.background)
            .navigationTitle("Mon profil")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Déconnexion", isPresented: $showLogoutAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Se déconnecter", role: .destructive) {
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print("Erreur de déconnexion : \(error.localizedDescription)")
                    }
                }
            } message: {
                Text("Voulez-vous vraiment vous déconnecter ?")
            }
        }
    }
}
