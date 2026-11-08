//
//  ContentView.swift
//  PlanDoctor
//
//  Created by azertt on 14/10/2026.
//



import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @State private var firebaseMessage = "Firebase n'a pas encore été testé."
    @State private var isLoading = false

    private let db = Firestore.firestore()

    
    func testFirebase() {
        isLoading = true
        firebaseMessage = "Authentification en cours..."

        Auth.auth().signInAnonymously { result, error in

            if let error = error {
                DispatchQueue.main.async {
                    firebaseMessage = "Erreur Auth : \(error.localizedDescription)"
                    isLoading = false
                }
                return
            }

            guard let user = result?.user else {
                DispatchQueue.main.async {
                    firebaseMessage = "Utilisateur introuvable."
                    isLoading = false
                }
                return
            }

            let data: [String: Any] = [
                "message": "Connexion réussie depuis PlantDoctor",
                "date": Timestamp(date: Date()),
                "device": "iOS",
                "userId": user.uid
            ]

            db.collection("connection_tests")
                .document("ios_test")
                .setData(data) { error in

                    DispatchQueue.main.async {
                        if let error = error {
                            firebaseMessage = "Erreur Firestore : \(error.localizedDescription)"
                        } else {
                            firebaseMessage = "Firebase connecté avec succès ! 🌱"
                        }

                        isLoading = false
                    }
                }
        }
    }


    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.97, blue: 0.92)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(.green)

                    Text("PlantDoctor")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.green)

                    Text("Prenez soin de vos plantes.")
                        .font(.title3)

                    Text("Détectez les maladies des feuilles grâce à l'intelligence artificielle.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Button(action: testFirebase) {
                        Label(
                            "Tester Firebase",
                            systemImage: "bolt.horizontal.circle.fill"
                        )
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(isLoading)
                    .padding(.horizontal, 24)

                    if isLoading {
                        ProgressView()
                    }

                    Text(firebaseMessage)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding()
            }
            .navigationTitle("Accueil")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
