
import SwiftUI
import PhotosUI

struct PlantDetectionView: View {
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var prediction: PlantPrediction?
    @State private var errorMessage: String?
    @State private var showResult = false
    @State private var showSaveErrorAlert = false
    @State private var showSaveErrorAfterResult = false
    private let coreMLService: CoreMLService? = try? CoreMLService()
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    
                    // MARK: Header
                    
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 65))
                            .foregroundStyle(PlantDoctorTheme.green)
                        
                        Text("Diagnostic de votre plante")
                            .font(.title2.bold())
                            .foregroundStyle(PlantDoctorTheme.text)
                        
                        Text("Importez une photo de votre feuille pour détecter une maladie.")
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
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 20)
                                )
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
                            .clipShape(
                                RoundedRectangle(cornerRadius: 20)
                            )
                        }
                    }
                    
                    // MARK: Photo Picker
                    
                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label(
                            "Choisir une photo",
                            systemImage: "photo"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(.white)
                        .background(PlantDoctorTheme.green)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .onChange(of: selectedPhoto) { _, newItem in
                        Task {
                            await loadImage(from: newItem)
                        }
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
                                ? "Analyse en cours..."
                                : "Lancer le diagnostic"
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
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    .disabled(selectedImage == nil || isAnalyzing)
                    
                    Text("L'analyse est effectuée directement sur votre appareil grâce à l'intelligence artificielle.")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
            .background(PlantDoctorTheme.background)
            .navigationTitle("Diagnostic")
            .navigationBarTitleDisplayMode(.inline)
            
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
            
            // MARK: Error Alert
            
            .alert(
                "Erreur",
                isPresented: Binding(
                    get: { errorMessage != nil },
                    set: {
                        if !$0 {
                            errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {
                    errorMessage = nil
                }
            } message: {
                Text(errorMessage ?? "Une erreur est survenue.")
            }
            .alert(
                "Sauvegarde impossible",
                isPresented: $showSaveErrorAlert
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(
                    errorMessage ??
                    "Le diagnostic a réussi, mais n'a pas été enregistré dans votre historique."
                )
            }
        }
    }
    
    
    // MARK: Load Image
    
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
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: Analyze Plant and Save
    
    // MARK: - Analyze Plant and Save
    @MainActor
    private func analyzePlant() async {
        guard let selectedImage else { return }
        
        guard let coreMLService else {
            errorMessage = "Impossible de charger le modèle Core ML."
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
            
            // 1. Analyse avec Core ML
            let result = try await Task.detached {
                try coreMLService.predict(image: image)
            }.value
            
            prediction = result
            
            // 2. Sauvegarde dans Firestore
            do {
                try await DiagnosisHistoryService.shared.saveDiagnosis(
                    prediction: result
                )
            } catch {
                // Le résultat reste disponible même si Firestore échoue.
                errorMessage = error.localizedDescription
                showSaveErrorAfterResult = true
            }
            
            // 3. Affichage du résultat
            showResult = true
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
}

