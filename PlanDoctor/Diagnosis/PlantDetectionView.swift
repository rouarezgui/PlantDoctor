
import SwiftUI
import PhotosUI
import UIKit

struct PlantDetectionView: View {

    // MARK: - States

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    @State private var isAnalyzing = false
    @State private var prediction: PlantPrediction?
    @State private var errorMessage: String?

    @State private var showResult = false
    @State private var showCamera = false
    @State private var showSaveErrorAlert = false
    @State private var showSaveErrorAfterResult = false

    @AppStorage("selectedAppLanguage")
    private var selectedLanguage = "fr"

    @Environment(\.locale) private var locale

    private let coreMLService: CoreMLService? = try? CoreMLService()

    // MARK: - Camera availability

    private var isCameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 25) {

                    // MARK: Header

                    VStack(spacing: 12) {

                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 65))
                            .foregroundStyle(PlantDoctorTheme.green)

                        Text("diagnosis.header")
                            .font(.title2.bold())
                            .foregroundStyle(PlantDoctorTheme.text)

                        Text("diagnosis.subtitle")
                            .font(.subheadline)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 25)

                    // MARK: Image Preview

                    Group {

                        if let selectedImage {

                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(maxHeight: 280)
                                .overlay {
                                    if isAnalyzing {
                                        LeafScanOverlay()
                                    }
                                }
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 20)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(
                                            isAnalyzing
                                            ? PlantDoctorTheme.green
                                            : Color.clear,
                                            lineWidth: 2
                                        )
                                }

                        } else {

                            VStack(spacing: 15) {

                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundStyle(PlantDoctorTheme.green)

                                Text("diagnosis.no_image")
                                    .foregroundStyle(PlantDoctorTheme.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 230)
                            .background(PlantDoctorTheme.softGreen)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 20)
                            )
                        }
                    }

                    // MARK: Camera and Gallery Buttons

                    HStack(spacing: 12) {

                        // Camera button

                        Button {

                            if isCameraAvailable {
                                showCamera = true
                            }

                        } label: {

                            Label(
                                "diagnosis.take_photo",
                                systemImage: "camera.fill"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(
                                isCameraAvailable
                                ? PlantDoctorTheme.green
                                : PlantDoctorTheme.secondary
                            )
                            .clipShape(
                                RoundedRectangle(cornerRadius: 15)
                            )
                        }
                        .disabled(!isCameraAvailable || isAnalyzing)

                        // Gallery button

                        PhotosPicker(
                            selection: $selectedPhoto,
                            matching: .images
                        ) {

                            Label(
                                "diagnosis.choose_photo",
                                systemImage: "photo"
                            )
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundStyle(.white)
                            .background(PlantDoctorTheme.green)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 15)
                            )
                        }
                        .disabled(isAnalyzing)
                        .onChange(of: selectedPhoto) { _, newItem in

                            Task {
                                await loadImage(from: newItem)
                            }
                        }
                    }

                    // Camera unavailable information

                    if !isCameraAvailable {

                        Text("diagnosis.camera_unavailable")
                            .font(.caption)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                            .multilineTextAlignment(.center)
                    }

                    // MARK: Analyze Button

                    Button {

                        Task {
                            await analyzePlant()
                        }

                    } label: {

                        HStack {

                            if isAnalyzing {

                                ProgressView()
                                    .tint(.white)

                            } else {

                                Image(systemName: "sparkles")
                            }

                            Text(
                                isAnalyzing
                                ? "diagnosis.analyzing"
                                : "diagnosis.start"
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(
                            selectedImage == nil || isAnalyzing
                            ? PlantDoctorTheme.secondary
                            : PlantDoctorTheme.green
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 15)
                        )
                    }
                    .disabled(selectedImage == nil || isAnalyzing)

                    // MARK: Description

                    Text("diagnosis.description")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .background(PlantDoctorTheme.background)
            .navigationTitle("diagnosis.title")
            .navigationBarTitleDisplayMode(.inline)

            // MARK: Camera Sheet

            .sheet(isPresented: $showCamera) {

                CameraPicker(
                    onImageCaptured: { image in

                        selectedImage = image
                        selectedPhoto = nil
                        prediction = nil
                        errorMessage = nil
                    },
                    onCancel: {
                        showCamera = false
                    }
                )
                .ignoresSafeArea()
            }

            // MARK: Result Sheet

            .sheet(
                isPresented: $showResult,
                onDismiss: {

                    if showSaveErrorAfterResult {

                        showSaveErrorAfterResult = false
                        showSaveErrorAlert = true
                    }
                }
            ) {

                if let prediction, let selectedImage {

                    DiagnosisResultView(
                        image: selectedImage,
                        prediction: prediction
                    )
                }
            }

            // MARK: Analysis Error Alert

            .alert(
                "common.error",
                isPresented: Binding(
                    get: {
                        errorMessage != nil && !showSaveErrorAlert
                    },
                    set: { newValue in

                        if !newValue {
                            errorMessage = nil
                        }
                    }
                )
            ) {

                Button("common.ok", role: .cancel) {
                    errorMessage = nil
                }

            } message: {

                Text(
                    errorMessage ?? "common.unknown_error"
                )
            }

            // MARK: Firestore Save Error Alert

            .alert(
                "diagnosis.save_error_title",
                isPresented: $showSaveErrorAlert
            ) {

                Button("common.ok", role: .cancel) {
                    errorMessage = nil
                }

            } message: {

                Text(
                    errorMessage ?? "diagnosis.save_error_message"
                )
            }
        }
    }

    // MARK: - Load Image from Gallery

    @MainActor
    private func loadImage(from item: PhotosPickerItem?) async {

        guard let item else { return }

        do {

            guard
                let data = try await item.loadTransferable(type: Data.self),
                let image = UIImage(data: data)
            else {
                throw CoreMLServiceError.invalidImage
            }

            selectedImage = image
            prediction = nil
            errorMessage = nil

        } catch {

            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Analyze Plant and Save

    @MainActor
    private func analyzePlant() async {

        guard let selectedImage else { return }

        guard let coreMLService else {

            errorMessage = "diagnosis.model_error"
            return
        }

        isAnalyzing = true
        prediction = nil
        errorMessage = nil

        defer {
            isAnalyzing = false
        }

        do {

            let image = selectedImage

            // 1. Core ML prediction

            let result = try await Task.detached {

                try coreMLService.predict(image: image)

            }.value

            prediction = result

            // 2. Save diagnosis to Firestore

            do {

                try await DiagnosisHistoryService.shared.saveDiagnosis(
                    prediction: result
                )

            } catch {

                // Keep the diagnosis result even if saving fails.

                errorMessage = error.localizedDescription
                showSaveErrorAfterResult = true
            }

            // 3. Display diagnosis result

            showResult = true

        } catch {

            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Animated Leaf Scanner

struct LeafScanOverlay: View {

    @State private var scanPosition: CGFloat = 0

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .top) {

                // Scanning light

                LinearGradient(
                    colors: [
                        .clear,
                        PlantDoctorTheme.green.opacity(0.18),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 90)
                .offset(
                    y: geometry.size.height * scanPosition - 45
                )

                // Scanning line

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                .clear,
                                PlantDoctorTheme.green,
                                .white,
                                PlantDoctorTheme.green,
                                .clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 3)
                    .shadow(
                        color: PlantDoctorTheme.green.opacity(0.8),
                        radius: 8
                    )
                    .offset(
                        y: geometry.size.height * scanPosition
                    )
            }
            .onAppear {

                scanPosition = 0

                withAnimation(
                    .linear(duration: 1.8)
                    .repeatForever(autoreverses: true)
                ) {
                    scanPosition = 1
                }
            }
        }
        .allowsHitTesting(false)
    }
}
