
import SwiftUI
import FirebaseAuth

struct SignupView: View {

    // MARK: - Environment

    @Environment(\.dismiss) private var dismiss

    // MARK: - Form States

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showPassword = false
    @State private var showConfirmPassword = false

    // MARK: - Firebase States

    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var registrationSucceeded = false

    // MARK: - Colors

    private let limeGreen = Color(
        red: 0.65,
        green: 0.95,
        blue: 0.05
    )

    private let darkGreen = Color(
        red: 0.01,
        green: 0.08,
        blue: 0.04
    )

    // MARK: - Body

    var body: some View {

        ZStack {

            // Background

            backgroundView

            ScrollView(showsIndicators: false) {

                VStack(spacing: 22) {

                    // Back Button

                    HStack {

                        Button {
                            dismiss()
                        } label: {

                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                Text("Connexion")
                            }
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white)
                        }

                        Spacer()
                    }
                    .padding(.top, 15)

                    // Logo

                    VStack(spacing: 10) {

                        ZStack {

                            RoundedRectangle(cornerRadius: 25)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.green,
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
                    .padding(.top, 10)

                    // Page Title

                    VStack(spacing: 8) {

                        Text("Créer un compte")
                            .font(.system(size: 29, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Rejoignez PlantDoctor et prenez soin de vos plantes 🌱")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 15)
                    }

                    // Signup Form

                    VStack(spacing: 18) {

                        // Full Name

                        glassTextField(
                            icon: "person",
                            placeholder: "Nom complet",
                            text: $fullName
                        )
                        .textContentType(.name)

                        // Email

                        glassTextField(
                            icon: "envelope",
                            placeholder: "Adresse e-mail",
                            text: $email
                        )
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textContentType(.emailAddress)

                        // Password

                        passwordField(
                            placeholder: "Mot de passe",
                            password: $password,
                            isVisible: $showPassword
                        )
                        .textContentType(.newPassword)

                        // Confirm Password

                        passwordField(
                            placeholder: "Confirmer le mot de passe",
                            password: $confirmPassword,
                            isVisible: $showConfirmPassword
                        )
                        .textContentType(.newPassword)

                        // Create Account Button

                        Button {
                            registerUser()
                        } label: {

                            Group {
                                if isLoading {

                                    ProgressView()
                                        .tint(.white)

                                } else {

                                    Text("Créer mon compte")
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
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.7 : 1)
                        .padding(.top, 8)
                    }
                    .padding(22)
                    .background(.ultraThinMaterial)
                    .background(Color.white.opacity(0.08))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 28)
                    )
                    .overlay {

                        RoundedRectangle(cornerRadius: 28)
                            .stroke(
                                Color.white.opacity(0.30),
                                lineWidth: 1
                            )
                    }
                    .shadow(
                        color: .black.opacity(0.25),
                        radius: 25
                    )

                    // Login Navigation

                    HStack(spacing: 6) {

                        Text("Vous avez déjà un compte ?")
                            .foregroundStyle(.white.opacity(0.85))

                        Button {
                            dismiss()
                        } label: {

                            Text("Se connecter")
                                .foregroundStyle(limeGreen)
                                .fontWeight(.bold)
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.bottom, 25)
                }
                .padding(.horizontal, 22)
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {

            Button("OK") {

                if registrationSucceeded {
                    dismiss()
                }
            }

        } message: {
            Text(alertMessage)
        }
        .preferredColorScheme(.dark)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Background View

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

            // Decorative Leaves

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

    // MARK: - Reusable Text Field

    private func glassTextField(
        icon: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {

        HStack(spacing: 14) {

            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.white)

            TextField(placeholder, text: text)
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .tint(.white)
        }
        .padding(.horizontal, 18)
        .frame(height: 60)
        .background(.white.opacity(0.13))
        .clipShape(Capsule())
        .overlay {

            Capsule()
                .stroke(
                    Color.white.opacity(0.22),
                    lineWidth: 1
                )
        }
    }

    // MARK: - Reusable Password Field

    private func passwordField(
        placeholder: String,
        password: Binding<String>,
        isVisible: Binding<Bool>
    ) -> some View {

        HStack(spacing: 14) {

            Image(systemName: "lock")
                .font(.system(size: 20))
                .foregroundStyle(.white)

            Group {

                if isVisible.wrappedValue {

                    TextField(
                        placeholder,
                        text: password
                    )

                } else {

                    SecureField(
                        placeholder,
                        text: password
                    )
                }
            }
            .font(.system(size: 15))
            .foregroundStyle(.white)
            .tint(.white)

            Button {

                isVisible.wrappedValue.toggle()

            } label: {

                Image(
                    systemName: isVisible.wrappedValue
                    ? "eye.slash"
                    : "eye"
                )
                .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 18)
        .frame(height: 60)
        .background(.white.opacity(0.13))
        .clipShape(Capsule())
        .overlay {

            Capsule()
                .stroke(
                    Color.white.opacity(0.22),
                    lineWidth: 1
                )
        }
    }

    // MARK: - Registration Action

    private func registerUser() {

        // 1. Validate required fields

        let name = fullName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let userEmail = email.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !name.isEmpty,
              !userEmail.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {

            alertTitle = "Champs obligatoires"
            alertMessage = "Veuillez remplir tous les champs."
            registrationSucceeded = false
            showAlert = true
            return
        }

        // 2. Validate email format

        guard userEmail.contains("@"),
              userEmail.contains(".") else {

            alertTitle = "Adresse e-mail invalide"
            alertMessage = "Veuillez saisir une adresse e-mail valide."
            registrationSucceeded = false
            showAlert = true
            return
        }

        // 3. Validate password confirmation

        guard password == confirmPassword else {

            alertTitle = "Mot de passe incorrect"
            alertMessage = "Les deux mots de passe ne correspondent pas."
            registrationSucceeded = false
            showAlert = true
            return
        }

        // 4. Validate password length

        guard password.count >= 6 else {

            alertTitle = "Mot de passe trop court"
            alertMessage = "Le mot de passe doit contenir au moins 6 caractères."
            registrationSucceeded = false
            showAlert = true
            return
        }

        // 5. Create Firebase account

        isLoading = true

        Auth.auth().createUser(
            withEmail: userEmail,
            password: password
        ) { result, error in

            if let error = error {

                DispatchQueue.main.async {

                    isLoading = false
                    alertTitle = "Erreur d'inscription"
                    alertMessage = error.localizedDescription
                    registrationSucceeded = false
                    showAlert = true
                }

                return
            }

            guard let user = result?.user else {

                DispatchQueue.main.async {

                    isLoading = false
                    alertTitle = "Erreur"
                    alertMessage = "Impossible de récupérer le compte créé."
                    registrationSucceeded = false
                    showAlert = true
                }

                return
            }

            // 6. Save full name in Firebase Auth profile

            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name

            changeRequest.commitChanges { error in

                DispatchQueue.main.async {

                    isLoading = false

                    if let error = error {

                        alertTitle = "Compte créé"
                        alertMessage = """
                        Votre compte existe, mais le nom du profil \
                        n'a pas pu être enregistré : \
                        \(error.localizedDescription)
                        """

                    } else {

                        alertTitle = "Bienvenue sur PlantDoctor !"
                        alertMessage = "Votre compte a été créé avec succès."
                    }

                    registrationSucceeded = true
                    showAlert = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SignupView()
    }
}
