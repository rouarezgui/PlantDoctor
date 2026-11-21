//
//  DiagnosisResultView.swift
//  PlanDoctor
//
//  Created by azertt on 18/11/2026.
//


import SwiftUI

struct DiagnosisResultView: View {

    let image: UIImage
    let prediction: PlantPrediction

    @Environment(\.dismiss) private var dismiss

    private var formattedClassName: String {
        prediction.className
            .replacingOccurrences(of: "___", with: " - ")
            .replacingOccurrences(of: "_", with: " ")
    }

    private var isHealthy: Bool {
        prediction.className.lowercased().hasSuffix("healthy")
    }

    private var confidencePercentage: String {
        String(format: "%.1f%%", prediction.confidence * 100)
    }

    var body: some View {

        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 260)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    VStack(spacing: 12) {

                        Image(
                            systemName: isHealthy
                            ? "checkmark.circle.fill"
                            : "exclamationmark.triangle.fill"
                        )
                        .font(.system(size: 55))
                        .foregroundStyle(
                            isHealthy ? .green : .orange
                        )

                        Text(isHealthy ? "Plante saine" : "Maladie détectée")
                            .font(.title2.bold())
                            .foregroundStyle(PlantDoctorTheme.text)

                        Text(formattedClassName)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {

                        Text("Score de prédiction")
                            .font(.headline)

                        HStack {
                            Text("Confiance du modèle")
                                .foregroundStyle(PlantDoctorTheme.secondary)

                            Spacer()

                            Text(confidencePercentage)
                                .fontWeight(.bold)
                                .foregroundStyle(PlantDoctorTheme.green)
                        }

                        ProgressView(
                            value: min(max(prediction.confidence, 0), 1)
                        )
                        .tint(PlantDoctorTheme.green)
                    }
                    .padding()
                    .background(PlantDoctorTheme.softGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                    Text("Ce résultat est une prédiction automatique du modèle IA. Il constitue une aide indicative et ne remplace pas l'avis d'un spécialiste des plantes.")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .background(PlantDoctorTheme.background)
            .navigationTitle("Résultat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fermer") {
                        dismiss()
                    }
                    .foregroundStyle(PlantDoctorTheme.green)
                }
            }
        }
    }
}
