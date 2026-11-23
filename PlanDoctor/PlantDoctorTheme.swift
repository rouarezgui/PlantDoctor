//
//  PlantDoctorTheme.swift
//  PlanDoctor
//
//  Created by azertt on 8/11/2026.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {

    case system = "system"
    case light = "light"
    case dark = "dark"

    var id: String { rawValue }

    
    var titleKey: LocalizedStringKey {
        switch self {
        case .system: return "theme.system"
        case .light: return "theme.light"
        case .dark: return "theme.dark"
        }
    }


    var icon: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

enum PlantDoctorTheme {

    static let green = Color(hex: 0x548542)

    // Vert adaptatif : clair ou foncé selon le thème
    static let softGreen = Color(
        uiColor: UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return UIColor(
                    red: 0.16,
                    green: 0.25,
                    blue: 0.16,
                    alpha: 1
                )
            } else {
                return UIColor(
                    red: 0.88,
                    green: 0.94,
                    blue: 0.82,
                    alpha: 1
                )
            }
        }
    )

    // Arrière-plan adaptatif
    static let background = Color(
        uiColor: UIColor { traits in
            if traits.userInterfaceStyle == .dark {
                return UIColor(
                    red: 0.08,
                    green: 0.12,
                    blue: 0.09,
                    alpha: 1
                )
            } else {
                return UIColor(
                    red: 0.96,
                    green: 0.97,
                    blue: 0.93,
                    alpha: 1
                )
            }
        }
    )

    // Couleurs de texte adaptatives
    static let text = Color.primary
    static let secondary = Color.secondary

    // Bordures et cartes
    static let border = Color.primary.opacity(0.12)
    static let card = Color(uiColor: .secondarySystemBackground)
}

extension Color {

    init(hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
