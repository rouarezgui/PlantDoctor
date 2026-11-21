//
//  HistoryView.swift
//  PlanDoctor
//
//  Created by azertt on 8/11/2026.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HistoryView: View {

    @State private var analyses: [DiagnosisRecord] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Chargement de votre historique...")
                        .tint(PlantDoctorTheme.green)

                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundStyle(.orange)

                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(PlantDoctorTheme.secondary)

                        Button("Réessayer") {
                            loadHistory()
                        }
                        .foregroundStyle(PlantDoctorTheme.green)
                    }
                    .padding()

                } else if analyses.isEmpty {
                    emptyState

                } else {
                    List {
                        ForEach(analyses) { analysis in
                            analysisRow(analysis)
                                .listRowBackground(
                                    PlantDoctorTheme.background
                                )
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(PlantDoctorTheme.background)
                }
            }
            .background(PlantDoctorTheme.background)
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        loadHistory()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(PlantDoctorTheme.green)
                    }
                }
            }
            .onAppear {
                loadHistory()
            }
        }
    }

    // MARK: Empty State

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 65))
                .foregroundStyle(PlantDoctorTheme.green)

            Text("Votre historique")
                .font(.title2.bold())
                .foregroundStyle(PlantDoctorTheme.text)

            Text("Vous n'avez pas encore effectué de diagnostic.")
                .font(.subheadline)
                .foregroundStyle(PlantDoctorTheme.secondary)
                .multilineTextAlignment(.center)

            Text("Vos prochaines analyses apparaîtront ici.")
                .font(.caption)
                .foregroundStyle(PlantDoctorTheme.secondary)
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: Analysis Row

    private func analysisRow(_ analysis: DiagnosisRecord) -> some View {
        HStack(spacing: 14) {

            Image(
                systemName: analysis.isHealthy
                ? "checkmark.circle.fill"
                : "exclamationmark.triangle.fill"
            )
            .font(.system(size: 30))
            .foregroundStyle(
                analysis.isHealthy ? .green : .orange
            )

            VStack(alignment: .leading, spacing: 6) {

                Text(formattedName(analysis.className))
                    .font(.headline)
                    .foregroundStyle(PlantDoctorTheme.text)

                Text(analysis.isHealthy ? "Plante saine" : "Maladie détectée")
                    .font(.caption)
                    .foregroundStyle(PlantDoctorTheme.secondary)

                Text(analysis.createdAt.formatted(
                    date: .abbreviated,
                    time: .shortened
                ))
                .font(.caption2)
                .foregroundStyle(PlantDoctorTheme.secondary)
            }

            Spacer()

            Text(
                String(format: "%.1f%%", analysis.confidence * 100)
            )
            .font(.subheadline.bold())
            .foregroundStyle(PlantDoctorTheme.green)
        }
        .padding(.vertical, 8)
    }

    // MARK: Load History

    private func loadHistory() {

        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Veuillez vous connecter pour consulter votre historique."
            isLoading = false
            return
        }

        isLoading = true
        errorMessage = nil

        db.collection("users")
            .document(userId)
            .collection("analyses")
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in

                isLoading = false

                if let error {
                    errorMessage = error.localizedDescription
                    return
                }

                guard let documents = snapshot?.documents else {
                    analyses = []
                    return
                }

                analyses = documents.compactMap { document in

                    let data = document.data()

                    guard
                        let className = data["className"] as? String,
                        let confidence = data["confidence"] as? Double,
                        let isHealthy = data["isHealthy"] as? Bool,
                        let timestamp = data["createdAt"] as? Timestamp
                    else {
                        return nil
                    }

                    return DiagnosisRecord(
                        id: document.documentID,
                        className: className,
                        confidence: confidence,
                        isHealthy: isHealthy,
                        createdAt: timestamp.dateValue()
                    )
                }
            }
    }

    // MARK: Format Class Name

    private func formattedName(_ name: String) -> String {
        name
            .replacingOccurrences(of: "___", with: " - ")
            .replacingOccurrences(of: "_", with: " ")
    }
}

#Preview {
    HistoryView()
}
