//
//  LoginView.swift
//  PlanDoctor
//
//  Created by azertt on 7/11/2026.
//

import SwiftUI
import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

struct LoginView: View {
    @AppStorage("selectedAppLanguage")
    private var selectedLanguage = "fr"

    // MARK: - Navigation

    var onLoginSuccess: (() -> Void)? = nil

    // MARK: - Form States

    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false

    // MARK: - Firebase States

    @State private var isLoading = false
    @State private var isGoogleSigningIn = false
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
                        HStack {
                            Spacer()

                            Menu {
                                Button("🇫🇷 Français") {
                                    selectedLanguage = "fr"
                                }

                                Button("🇬🇧 English") {
                                    selectedLanguage = "en"
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "globe")
                                    Text(selectedLanguage == "fr" ? "FR" : "EN")
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 10))
                                }
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 9)
                                .background(.white.opacity(0.15))
                                .clipShape(Capsule())
                            }
                        }

                        Spacer(minLength: 35)

                        // MARK: Logo

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

                        // MARK: Welcome Text

                        VStack(spacing: 9) {
                            Text("login.welcome")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundStyle(.white)
                                .multilineTextAlignment(.center)

                            Text("login.subtitle")
                                .font(.system(size: 14))
                                .foregroundStyle(.white.opacity(0.75))
                        }

                        // MARK: Login Form

                        VStack(spacing: 18) {

                            // Email

                            HStack(spacing: 14) {
                                Image(systemName: "envelope")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 20))

                                TextField(
                                    "login.email_placeholder",
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
                                            "login.password_placeholder",
                                            text: $password
                                        )
                                    } else {
                                        SecureField(
                                            "login.password_placeholder",
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

                                Button {
                                    resetPassword()
                                } label: {
                                    Text("login.forgot_password")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(limeGreen)
                                }
                                .disabled(
                                    isResettingPassword ||
                                    isLoading ||
                                    isGoogleSigningIn
                                )
                            }

                            // Email Login Button

                            Button {
                                loginUser()
                            } label: {
                                Group {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("login.sign_in")
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
                            .disabled(
                                isLoading ||
                                isResettingPassword ||
                                isGoogleSigningIn
                            )
                            .opacity(isLoading ? 0.7 : 1)

                            // Separator

                            HStack {
                                Rectangle()
                                    .fill(.white.opacity(0.3))
                                    .frame(height: 1)

                                Text("login.or")
                                    .font(.caption.bold())
                                    .foregroundStyle(.white.opacity(0.7))

                                Rectangle()
                                    .fill(.white.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 3)

                            // Google Login Button

                            Button {
                                signInWithGoogle()
                            } label: {
                                HStack(spacing: 12) {
                                    if isGoogleSigningIn {
                                        ProgressView()
                                            .tint(.black)
                                    } else {
                                        Image(systemName: "g.circle.fill")
                                            .font(.system(size: 23))
                                    }

                                    Text(
                                        isGoogleSigningIn
                                        ? "login.google_loading"
                                        : "login.google"
                                    )
                                    .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundStyle(.black.opacity(0.85))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(.white)
                                .clipShape(Capsule())
                            }
                            .disabled(
                                isLoading ||
                                isResettingPassword ||
                                isGoogleSigningIn
                            )
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

                        // MARK: Signup Navigation

                        HStack(spacing: 6) {
                            Text("login.no_account")
                                .foregroundStyle(.white.opacity(0.85))

                            NavigationLink(
                                destination: SignupView()
                            ) {
                                Text("login.create_account")
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
            .alert(
                LocalizedStringKey(alertTitle),
                isPresented: $showAlert
            ) {
                Button("common.ok") {
                    if loginSucceeded {
                        onLoginSuccess?()
                    }
                }
            } message: {
                Text(LocalizedStringKey(alertMessage))
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

    // MARK: - Email Login

    private func loginUser() {

        let userEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !userEmail.isEmpty, !password.isEmpty else {
            alertTitle = "login.required_title"
            alertMessage = "login.required_message"
            loginSucceeded = false
            showAlert = true
            return
        }

        guard userEmail.contains("@"), userEmail.contains(".") else {
            alertTitle = "login.invalid_email_title"
            alertMessage = "login.invalid_email_message"
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
                    alertTitle = "login.failed_title"
                    alertMessage = error.localizedDescription
                    loginSucceeded = false
                    showAlert = true
                    return
                }

                guard result?.user != nil else {
                    alertTitle = "common.error"
                    alertMessage = "login.account_retrieval_error"
                    loginSucceeded = false
                    showAlert = true
                    return
                }

                alertTitle = "login.success_title"
                alertMessage = "login.success_message"
                loginSucceeded = true
                showAlert = true
            }
        }
    }

    // MARK: - Google Sign In

    private func signInWithGoogle() {

        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showError(
                title: "login.configuration_error",
                message: "login.client_id_missing"
            )
            return
        }

        guard let presentingViewController = getRootViewController() else {
            showError(
                title: "common.error",
                message: "login.google_window_error"
            )
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(
            clientID: clientID
        )

        isGoogleSigningIn = true

        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController
        ) { signInResult, error in

            if let error = error {
                DispatchQueue.main.async {
                    isGoogleSigningIn = false

                    // L'utilisateur peut avoir annulé la fenêtre Google.
                    if (error as NSError).code == -5 {
                        return
                    }

                    showError(
                        title: "login.google_failed",
                        message: error.localizedDescription
                    )
                }
                return
            }

            guard
                let user = signInResult?.user,
                let idToken = user.idToken?.tokenString
            else {
                DispatchQueue.main.async {
                    isGoogleSigningIn = false
                    showError(
                        title: "login.google_error",
                        message: "login.google_token_error"
                    )
                }
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: accessToken
            )

            Auth.auth().signIn(with: credential) { result, error in

                DispatchQueue.main.async {
                    isGoogleSigningIn = false

                    if let error = error {
                        showError(
                            title: "login.firebase_error",
                            message: error.localizedDescription
                        )
                        return
                    }

                    guard result?.user != nil else {
                        showError(
                            title: "common.error",
                            message: "login.account_retrieval_error"
                        )
                        return
                    }

                    alertTitle = "login.success_title"
                    alertMessage = "login.google_success_message"
                    loginSucceeded = true
                    showAlert = true
                }
            }
        }
    }

    // MARK: - Get Root View Controller

    private func getRootViewController() -> UIViewController? {

        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene

        return windowScene?
            .windows
            .first(where: { $0.isKeyWindow })?
            .rootViewController
    }

    // MARK: - Error Helper

    private func showError(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        loginSucceeded = false
        showAlert = true
    }

    // MARK: - Password Reset

    private func resetPassword() {

        let userEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !userEmail.isEmpty else {
            alertTitle = "login.reset_email_required_title"
            alertMessage = "login.reset_email_required_message"
            loginSucceeded = false
            showAlert = true
            return
        }

        guard userEmail.contains("@"), userEmail.contains(".") else {
            alertTitle = "login.invalid_email_title"
            alertMessage = "login.invalid_email_message"
            loginSucceeded = false
            showAlert = true
            return
        }

        isResettingPassword = true

        Auth.auth().sendPasswordReset(withEmail: userEmail) { error in

            DispatchQueue.main.async {
                isResettingPassword = false

                if let error = error {
                    alertTitle = "common.error"
                    alertMessage = error.localizedDescription
                } else {
                    alertTitle = "login.reset_success_title"
                    alertMessage = "login.reset_success_message"
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
