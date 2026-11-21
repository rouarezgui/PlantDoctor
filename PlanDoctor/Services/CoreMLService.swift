//
//  CoreMLService.swift
//  PlanDoctor
//
//  Created by azertt on 18/11/2026.
//


import Foundation
import CoreML
import UIKit

// MARK: - Prediction Result

struct PlantPrediction {
    let className: String
    let confidence: Double
}

// MARK: - Core ML Errors

enum CoreMLServiceError: LocalizedError {
    case modelNotFound
    case classNamesNotFound
    case invalidImage
    case invalidOutput
    case predictionFailed(String)

    var errorDescription: String? {
        switch self {
        case .modelNotFound:
            return "Le modèle PlantDiseaseClassifier est introuvable."
        case .classNamesNotFound:
            return "Le fichier class_names.json est introuvable."
        case .invalidImage:
            return "Impossible de préparer cette image."
        case .invalidOutput:
            return "Le modèle a retourné un résultat invalide."
        case .predictionFailed(let message):
            return "Erreur de prédiction : \(message)"
        }
    }
}

// MARK: - Core ML Service

final class CoreMLService {

    private let model: MLModel
    private let classNames: [String]

    private let imageSize = 224

    init() throws {

        // Load compiled Core ML model
        guard let modelURL = Bundle.main.url(
            forResource: "PlantDiseaseClassifier",
            withExtension: "mlmodelc"
        ) else {
            throw CoreMLServiceError.modelNotFound
        }

        let configuration = MLModelConfiguration()
        configuration.computeUnits = .all

        model = try MLModel(
            contentsOf: modelURL,
            configuration: configuration
        )

        // Load the 33 class names
        guard let jsonURL = Bundle.main.url(
            forResource: "class_names",
            withExtension: "json"
        ) else {
            throw CoreMLServiceError.classNamesNotFound
        }

        let data = try Data(contentsOf: jsonURL)
        classNames = try JSONDecoder().decode(
            [String].self,
            from: data
        )

        guard classNames.count == 33 else {
            throw CoreMLServiceError.invalidOutput
        }
    }

    // MARK: - Predict

    func predict(image: UIImage) throws -> PlantPrediction {

        let inputArray = try prepareImage(image)

        let inputProvider = try MLDictionaryFeatureProvider(
            dictionary: [
                "image": MLFeatureValue(
                    multiArray: inputArray
                )
            ]
        )

        let output = try model.prediction(
            from: inputProvider
        )

        guard let probabilities = output
            .featureValue(for: "Identity")?
            .multiArrayValue else {
            throw CoreMLServiceError.invalidOutput
        }

        guard probabilities.count == 33 else {
            throw CoreMLServiceError.invalidOutput
        }

        // Find the class with the highest score
        var bestIndex = 0
        var bestScore: Float = -Float.infinity

        for index in 0..<33 {
            let score = probabilities[index].floatValue

            if score > bestScore {
                bestScore = score
                bestIndex = index
            }
        }

        return PlantPrediction(
            className: classNames[bestIndex],
            confidence: Double(bestScore)
        )
    }

    // MARK: - Image Preparation

    private func prepareImage(
        _ image: UIImage
    ) throws -> MLMultiArray {

        // Resize to 224 x 224 and respect image orientation
        let size = CGSize(
            width: imageSize,
            height: imageSize
        )

        let renderer = UIGraphicsImageRenderer(
            size: size,
            format: UIGraphicsImageRendererFormat()
        )

        let resizedImage = renderer.image { context in
            image.draw(
                in: CGRect(origin: .zero, size: size)
            )
        }

        guard let cgImage = resizedImage.cgImage else {
            throw CoreMLServiceError.invalidImage
        }

        // Extract RGB pixels
        var pixelData = [UInt8](
            repeating: 0,
            count: imageSize * imageSize * 4
        )

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let bitmapInfo =
            CGImageAlphaInfo.premultipliedLast.rawValue |
            CGBitmapInfo.byteOrder32Big.rawValue

        let contextCreated = pixelData.withUnsafeMutableBytes {
            pointer -> Bool in

            guard let context = CGContext(
                data: pointer.baseAddress,
                width: imageSize,
                height: imageSize,
                bitsPerComponent: 8,
                bytesPerRow: imageSize * 4,
                space: colorSpace,
                bitmapInfo: bitmapInfo
            ) else {
                return false
            }

            context.draw(
                cgImage,
                in: CGRect(origin: .zero, size: size)
            )

            return true
        }

        guard contextCreated else {
            throw CoreMLServiceError.invalidImage
        }

        // Model input: [1, 224, 224, 3]
        let array = try MLMultiArray(
            shape: [
                1,
                NSNumber(value: imageSize),
                NSNumber(value: imageSize),
                3
            ],
            dataType: .float32
        )

        // IMPORTANT:
        // Do not normalize pixels here.
        // The model already contains Rescaling:
        // pixel / 127.5 - 1

        for y in 0..<imageSize {
            for x in 0..<imageSize {
                let pixelIndex = (y * imageSize + x) * 4

                for channel in 0..<3 {
                    let pixelValue = Float(
                        pixelData[pixelIndex + channel]
                    )

                    array[
                        [
                            0,
                            NSNumber(value: y),
                            NSNumber(value: x),
                            NSNumber(value: channel)
                        ]
                    ] = NSNumber(value: pixelValue)
                }
            }
        }

        return array
    }
}

