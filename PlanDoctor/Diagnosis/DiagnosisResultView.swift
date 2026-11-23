//
//  DiagnosisResultView.swift
//  PlanDoctor
//
//  Created by azertt on 18/11/2026.
//

import SwiftUI
import UIKit

struct DiagnosisResultView: View {

    let image: UIImage
    let prediction: PlantPrediction

    @Environment(\.dismiss) private var dismiss

    @StateObject private var interstitialAd = InterstitialAdManager()

    // MARK: - Animation States

    @State private var showResult = false
    @State private var showScore = false
    @State private var animatedConfidence: Double = 0

    // MARK: - Formatted Class Name

    private var formattedClassName: String {
        prediction.className
            .replacingOccurrences(of: "___", with: " - ")
            .replacingOccurrences(of: "_", with: " ")
    }

    // MARK: - Plant Health Status

    private var isHealthy: Bool {
        prediction.className.lowercased().hasSuffix("healthy")
    }

    // MARK: - Confidence Percentage

    private var confidencePercentage: String {
        String(format: "%.1f%%", prediction.confidence * 100)
    }

    private var validConfidence: Double {
        min(max(prediction.confidence, 0), 1)
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 24) {

                    // MARK: - Plant Image

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 260)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 20)
                        )
                        .opacity(showResult ? 1 : 0)
                        .animation(
                            .easeIn(duration: 0.6),
                            value: showResult
                        )

                    // MARK: - Animated Diagnosis Result

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
                        .symbolEffect(.bounce, value: showResult)

                        Text(
                            isHealthy
                            ? "result.healthy"
                            : "result.disease_detected"
                        )
                        .font(.title2.bold())
                        .foregroundStyle(PlantDoctorTheme.text)

                        Text(formattedClassName)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                    }
                    .opacity(showResult ? 1 : 0)
                    .scaleEffect(showResult ? 1 : 0.75)
                    .offset(y: showResult ? 0 : 20)

                    // MARK: - Animated Prediction Score

                    VStack(alignment: .leading, spacing: 12) {

                        Text("result.prediction_score")
                            .font(.headline)
                            .foregroundStyle(PlantDoctorTheme.text)

                        HStack {

                            Text("result.model_confidence")
                                .foregroundStyle(PlantDoctorTheme.secondary)

                            Spacer()

                            Text(confidencePercentage)
                                .fontWeight(.bold)
                                .foregroundStyle(PlantDoctorTheme.green)
                        }

                        ProgressView(value: animatedConfidence)
                            .tint(PlantDoctorTheme.green)
                    }
                    .padding()
                    .background(PlantDoctorTheme.softGreen)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 18)
                    )
                    .opacity(showScore ? 1 : 0)
                    .offset(y: showScore ? 0 : 15)

                    // MARK: - Disclaimer

                    Text("result.disclaimer")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .opacity(showScore ? 1 : 0)
                }
                .padding()
            }
            .background(PlantDoctorTheme.background)

            // MARK: - Navigation

            .navigationTitle("result.title")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    Button("common.close") {

                        print("🔵 CLOSE BUTTON CLICKED")

                        interstitialAd.showAd {

                            print("🟢 DISMISSING DIAGNOSIS VIEW")
                            dismiss()
                        }
                    }
                    .foregroundStyle(PlantDoctorTheme.green)
                }
            }

            // MARK: - Start Animations

            .onAppear {

                withAnimation(
                    .spring(response: 0.6, dampingFraction: 0.7)
                ) {
                    showResult = true
                }

                withAnimation(
                    .easeOut(duration: 1.3).delay(0.35)
                ) {
                    animatedConfidence = validConfidence
                }

                withAnimation(
                    .easeOut(duration: 0.6).delay(0.25)
                ) {
                    showScore = true
                }
            }
        }
    }
}
