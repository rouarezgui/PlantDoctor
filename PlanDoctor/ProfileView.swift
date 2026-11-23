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

                // MARK: - Profile Image

                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 90))
                    .foregroundStyle(PlantDoctorTheme.green)

                // MARK: - User Information

                VStack(spacing: 8) {

                    if let displayName = user.displayName,
                       !displayName.isEmpty {
                        Text(displayName)
                            .font(.title2.bold())
                            .foregroundStyle(PlantDoctorTheme.text)
                    } else {
                        Text("profile.default_name")
                            .font(.title2.bold())
                            .foregroundStyle(PlantDoctorTheme.text)
                    }

                    if let email = user.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                    } else {
                        Text("profile.no_email")
                            .font(.subheadline)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                    }
                }

                // MARK: - Account Information

                VStack(alignment: .leading, spacing: 15) {

                    Label(
                        "profile.account",
                        systemImage: "person"
                    )
                    .font(.headline)

                    Divider()

                    Text("profile.email")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)

                    if let email = user.email {
                        Text(email)
                            .font(.body)
                            .foregroundStyle(PlantDoctorTheme.text)
                    } else {
                        Text("profile.unavailable")
                            .font(.body)
                            .foregroundStyle(PlantDoctorTheme.text)
                    }

                    Divider()

                    Text("profile.uid")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)

                    Text(user.uid)
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.text)
                        .textSelection(.enabled)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(PlantDoctorTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // MARK: - Logout Button

                Button(role: .destructive) {

                    showLogoutAlert = true

                } label: {

                    Label(
                        "profile.logout",
                        systemImage: "rectangle.portrait.and.arrow.right"
                    )
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
            .navigationTitle("profile.title")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: - Logout Confirmation

            .alert(
                "profile.logout_title",
                isPresented: $showLogoutAlert
            ) {

                Button("profile.cancel", role: .cancel) { }

                Button("profile.logout", role: .destructive) {

                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print(
                            "Logout error: \(error.localizedDescription)"
                        )
                    }
                }

            } message: {

                Text("profile.logout_confirmation")
            }
        }
    }
}
