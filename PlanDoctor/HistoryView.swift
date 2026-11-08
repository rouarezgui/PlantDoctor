//
//  HistoryView.swift
//  PlanDoctor
//
//  Created by azertt on 8/11/2026.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
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
            .background(PlantDoctorTheme.background)
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

