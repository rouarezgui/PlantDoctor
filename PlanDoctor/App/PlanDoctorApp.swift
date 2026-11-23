//
//  PlanDoctorApp.swift
//  PlanDoctor
//
//  Created by azertt on 14/10/2026.
//
import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct PlanDoctorApp: App {

    @AppStorage("selectedAppTheme")
    private var selectedTheme = AppTheme.system.rawValue

    @AppStorage("selectedAppLanguage")
    private var selectedLanguage = "fr"

    init() {
        FirebaseApp.configure()

        GADMobileAds.sharedInstance().start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            SplashView()
                .preferredColorScheme(
                    AppTheme(rawValue: selectedTheme)?.colorScheme
                )
                .environment(
                    \.locale,
                    Locale(identifier: selectedLanguage)
                )
        }
    }
}
