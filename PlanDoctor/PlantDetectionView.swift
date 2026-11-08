//
//  PlantDetectionView.swift
//  PlanDoctor
//
//  Created by azertt on 8/11/2026.
//

import SwiftUI
import PhotosUI

struct PlantDetectionView: View {
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 65))
                            .foregroundStyle(PlantDoctorTheme.green)

                        Text("Diagnostic de votre plante")
                            .font(.title2.bold())
                            .foregroundStyle(PlantDoctorTheme.text)

                        Text("Prenez ou importez une photo de votre plante pour préparer son analyse.")
                            .font(.subheadline)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 25)

                    Group {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 280)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            VStack(spacing: 15) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundStyle(PlantDoctorTheme.green)

                                Text("Aucune image sélectionnée")
                                    .foregroundStyle(PlantDoctorTheme.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 230)
                            .background(PlantDoctorTheme.softGreen)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                        }
                    }

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label("Choisir une photo", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(PlantDoctorTheme.green)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            guard let data = try? await newItem?.loadTransferable(type: Data.self),
                                  let image = UIImage(data: data) else {
                                return
                            }

                            selectedImage = image
                        }
                    }

                    Button {
                        // L'intégration du modèle IA sera ajoutée ici.
                    } label: {
                        Label("Lancer le diagnostic", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(
                                selectedImage == nil
                                ? PlantDoctorTheme.secondary
                                : PlantDoctorTheme.green
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .disabled(selectedImage == nil)

                    Text("Le résultat de l'analyse apparaîtra ici après l'intégration du modèle IA.")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .background(PlantDoctorTheme.background)
            .navigationTitle("Diagnostic")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

