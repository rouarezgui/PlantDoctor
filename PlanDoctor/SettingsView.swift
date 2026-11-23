//
//  SettingsView.swift
//  PlanDoctor
//
//  Created by azertt on 21/11/2026.
//

import SwiftUI

struct SettingsView: View {

    @AppStorage("selectedAppTheme")
    private var selectedTheme = AppTheme.system.rawValue

    @AppStorage("selectedAppLanguage")
    private var selectedLanguage = "fr"

    private var themeBinding: Binding<AppTheme> {
        Binding(
            get: {
                AppTheme(rawValue: selectedTheme) ?? .system
            },
            set: {
                selectedTheme = $0.rawValue
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {

                Section("settings.appearance") {

                    Picker("settings.theme", selection: themeBinding) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(
                                theme.titleKey,
                                systemImage: theme.icon
                            )
                            .tag(theme)
                        }
                    }

                    HStack {
                        Text("settings.selected_theme")
                        Spacer()
                        Text(themeBinding.wrappedValue.titleKey)
                            .foregroundStyle(.secondary)
                    }

                    Picker("settings.language", selection: $selectedLanguage) {
                        Text("language.french").tag("fr")
                        Text("language.english").tag("en")
                    }
                }

                Section("settings.about") {
                    Label("PlantDoctor", systemImage: "leaf.fill")

                    HStack {
                        Text("settings.version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("tab.settings")
        }
    }
}

#Preview {
    SettingsView()
}
