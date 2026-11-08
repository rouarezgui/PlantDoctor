//
//  LoginView.swift
//  PlanDoctor
//
//  Created by azertt on 7/11/2026.
//


import SwiftUI
import FirebaseAuth

struct LoginView: View {

    // MARK: - Navigation

    var onLoginSuccess: (() -> Void)? = nil

    // MARK: - Form States

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    // MARK: - Firebase States

    @State private var isLoading = false
    @State private var isResettingPassword = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var loginSucceeded = false

    // MARK: - Colors

    private let limeGreen = Color(
        red: 0.65,
        green: 0.95,
        blue: 0.05
    )

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ZStack {

                backgroundView

                ScrollView(showsIndicators: false) {

                    VStack(spacing: 25) {

                        Spacer(minLength: 35)

                        // MARK: - Logo

                        VStack(spacing: 12) {

                            ZStack {

                                RoundedRectangle(cornerRadius: 25)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                .green,
                                                Color(
                                                    red: 0.15,
                                                    green: 0.45,
                                                    blue: 0.08
                                                )
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 85, height: 85)

                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 42))
                                    .foregroundStyle(.white)
                            }
                            .shadow(
                                color: limeGreen.opacity(0.3),
                                radius: 20
                            )

                            Text("PlantDoctor")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        // MARK: - Welcome Text

                        VStack(spacing: 9) {

                            Text("Bienvenue sur PlantDoctor")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)

                            Text("Connectez-vous à votre compte")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.75))
                        }

                        // MARK: - Login Form

                        VStack(spacing: 18) {

                            // Email

                            HStack(spacing: 14) {

                                Image(systemName: "envelope")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))

                                TextField(
                                    "Adresse e-mail",
                                    text: $email
                                )
                                .foregroundStyle(.white)
                                .tint(.white)
                                .keyboardType(.emailAddress)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .textContentType(.emailAddress)
                            }
                            .glassFieldStyle()

                            // Password

                            HStack(spacing: 14) {

                                Image(systemName: "lock")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))

                                Group {

                                    if showPassword {

                                        TextField(
                                            "Mot de passe",
                                            text: $password
                                        )

                                    } else {

                                        SecureField(
                                            "Mot de passe",
                                            text: $password
                                        )
                                    }
                                }
                                .foregroundStyle(.white)
                                .tint(.white)
                                .textContentType(.password)

                                Button {
                                    showPassword.toggle()
                                } label: {

                                    Image(
                                        systemName: showPassword
                                        ? "eye.slash"
                                        : "eye"
                                    )
                                    .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                            .glassFieldStyle()

                            // Forgot Password

                            HStack {

                                Spacer()

                                Button("Mot de passe oublié ?") {
                                    resetPassword()
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(limeGreen)
                                .disabled(isResettingPassword || isLoading)
                            }

                            // Login Button

                            Button {
                                loginUser()
                            } label: {

                                Group {

                                    if isLoading {

                                        ProgressView()
                                            .tint(.white)

                                    } else {

                                        Text("Se connecter")
                                            .font(
                                                .system(
                                                    size: 17,
                                                    weight: .bold
                                                )
                                            )
                                    }
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            limeGreen,
                                            Color(
                                                red: 0.35,
                                                green: 0.75,
                                                blue: 0.02
                                            )
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(
                                    color: limeGreen.opacity(0.35),
                                    radius: 15,
                                    y: 5
                                )
                            }
                            .disabled(isLoading || isResettingPassword)
                            .opacity(isLoading ? 0.7 : 1)
                        }
                        .padding(22)
                        .background(.ultraThinMaterial)
                        .background(.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .overlay {

                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    .white.opacity(0.30),
                                    lineWidth: 1
                                )
                        }

                        // MARK: - Signup Navigation

                        HStack(spacing: 6) {

                            Text("Vous n'avez pas de compte ?")
                                .foregroundStyle(.white.opacity(0.85))

                            NavigationLink(
                                destination: SignupView()
                            ) {

                                Text("Créer un compte")
                                    .foregroundStyle(limeGreen)
                                    .fontWeight(.bold)
                            }
                        }
                        .font(.system(size: 14))

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 22)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .alert(alertTitle, isPresented: $showAlert) {

                Button("OK") {

                    if loginSucceeded {
                        onLoginSuccess?()
                    }
                }

            } message: {

                Text(alertMessage)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Background

    private var backgroundView: some View {

        ZStack {

            LinearGradient(
                colors: [
                    Color(red: 0.01, green: 0.08, blue: 0.04),
                    Color(red: 0.02, green: 0.23, blue: 0.10),
                    Color(red: 0.01, green: 0.10, blue: 0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.green.opacity(0.35))
                .frame(width: 250)
                .blur(radius: 90)
                .offset(x: 140, y: -280)

            Circle()
                .fill(limeGreen.opacity(0.15))
                .frame(width: 230)
                .blur(radius: 85)
                .offset(x: -150, y: 300)

            Image(systemName: "leaf.fill")
                .font(.system(size: 150))
                .foregroundStyle(.green.opacity(0.25))
                .rotationEffect(.degrees(-35))
                .offset(x: 150, y: -320)

            Image(systemName: "leaf.fill")
                .font(.system(size: 120))
                .foregroundStyle(.green.opacity(0.20))
                .rotationEffect(.degrees(35))
                .offset(x: -150, y: 350)
        }
        .ignoresSafeArea()
    }

    // MARK: - Login Action

    private func loginUser() {

        let userEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !userEmail.isEmpty, !password.isEmpty else {

            alertTitle = "Champs obligatoires"
            alertMessage = "Veuillez saisir votre e-mail et votre mot de passe."
            loginSucceeded = false
            showAlert = true
            return
        }

        isLoading = true

        Auth.auth().signIn(
            withEmail: userEmail,
            password: password
        ) { result, error in

            DispatchQueue.main.async {

                isLoading = false

                if let error = error {

                    alertTitle = "Échec de connexion"
                    alertMessage = error.localizedDescription
                    loginSucceeded = false
                    showAlert = true

                    return
                }

                guard result?.user != nil else {

                    alertTitle = "Erreur"
                    alertMessage = "Impossible de récupérer votre compte."
                    loginSucceeded = false
                    showAlert = true
                    return
                }

                alertTitle = "Connexion réussie"
                alertMessage = "Bienvenue sur PlantDoctor ! 🌱"
                loginSucceeded = true
                showAlert = true
            }
        }
    }

    // MARK: - Password Reset

    private func resetPassword() {

        let userEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !userEmail.isEmpty else {

            alertTitle = "Adresse e-mail requise"
            alertMessage = "Saisissez votre adresse e-mail pour recevoir le lien de réinitialisation."
            loginSucceeded = false
            showAlert = true
            return
        }

        isResettingPassword = true

        Auth.auth().sendPasswordReset(
            withEmail: userEmail
        ) { error in

            DispatchQueue.main.async {

                isResettingPassword = false

                if let error = error {

                    alertTitle = "Erreur"
                    alertMessage = error.localizedDescription

                } else {

                    alertTitle = "E-mail envoyé"
                    alertMessage = "Consultez votre boîte e-mail pour réinitialiser votre mot de passe."
                }

                loginSucceeded = false
                showAlert = true
            }
        }
    }
}

// MARK: - Reusable Glass Field Style

private extension View {

    func glassFieldStyle() -> some View {

        self
            .padding(.horizontal, 18)
            .frame(height: 60)
            .background(.white.opacity(0.13))
            .clipShape(Capsule())
            .overlay {

                Capsule()
                    .stroke(
                        .white.opacity(0.22),
                        lineWidth: 1
                    )
            }
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}
