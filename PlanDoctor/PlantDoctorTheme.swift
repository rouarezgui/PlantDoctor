//
//  PlantDoctorTheme.swift
//  PlanDoctor
//
//  Created by azertt on 8/11/2026.
//

import SwiftUI

enum PlantDoctorTheme {
    static let background = Color(hex: 0xF5F8ED)
    static let green = Color(hex: 0x548542)
    static let softGreen = Color(hex: 0xE0EFD0)
    static let text = Color(hex: 0x263D2A)
    static let secondary = Color(hex: 0x819078)
    static let border = Color(hex: 0xE0E8D8)
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

