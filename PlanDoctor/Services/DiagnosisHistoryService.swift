//
//  DiagnosisHistoryService.swift
//  PlanDoctor
//
//  Created by azertt on 18/11/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

// MARK: - Diagnosis Record

struct DiagnosisRecord: Identifiable {

    let id: String
    let className: String
    let confidence: Double
    let isHealthy: Bool
    let createdAt: Date
}

// MARK: - Diagnosis History Service

final class DiagnosisHistoryService {

    static let shared = DiagnosisHistoryService()

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Save Diagnosis

    func saveDiagnosis(prediction: PlantPrediction) async throws {

        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "DiagnosisHistory",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Vous devez être connecté pour sauvegarder une analyse."
                ]
            )
        }

        let isHealthy = prediction.className
            .lowercased()
            .hasSuffix("healthy")

        let data: [String: Any] = [
            "userId": userId,
            "className": prediction.className,
            "confidence": prediction.confidence,
            "isHealthy": isHealthy,
            "createdAt": FieldValue.serverTimestamp()
        ]

        let collection = db
            .collection("users")
            .document(userId)
            .collection("analyses")

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in

            collection.addDocument(data: data) { error in

                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    // MARK: - Fetch Diagnosis History

    func fetchHistory() async throws -> [DiagnosisRecord] {

        guard let userId = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "DiagnosisHistory",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        "Vous devez être connecté pour consulter votre historique."
                ]
            )
        }

        let snapshot = try await db
            .collection("users")
            .document(userId)
            .collection("analyses")
            .order(by: "createdAt", descending: true)
            .getDocuments()

        let records: [DiagnosisRecord] = snapshot.documents.compactMap { document in

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

        return records
    }
}
