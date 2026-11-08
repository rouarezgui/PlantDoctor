//
//  PlanDoctorApp.swift
//  PlanDoctor
//
//  Created by azertt on 14/10/2026.
//

import SwiftUI
import FirebaseCore

@main
struct PlanDoctorApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
