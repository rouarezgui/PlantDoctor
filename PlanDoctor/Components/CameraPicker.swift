//
//  CameraPicker.swift
//  PlanDoctor
//
//  Created by azertt on 23/11/2026.
//

import SwiftUI
import UIKit

struct CameraPicker: UIViewControllerRepresentable {

    let onImageCaptured: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(
        context: Context
    ) -> UIImagePickerController {

        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        picker.allowsEditing = false

        return picker
    }

    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject,
                             UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate {

        let parent: CameraPicker

        init(_ parent: CameraPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info:
                [UIImagePickerController.InfoKey: Any]
        ) {

            if let image = info[.originalImage] as? UIImage {
                parent.onImageCaptured(image)
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(
            _ picker: UIImagePickerController
        ) {
            parent.onCancel()
            picker.dismiss(animated: true)
        }
    }
}
