//
//  HomeView.swift
//  PlanDoctor
//
//  Created by azertt on 8/11/2026.
//

import SwiftUI
import FirebaseAuth

// MARK: - Home View

struct HomeView: View {

    let user: FirebaseAuth.User

    @StateObject private var weatherViewModel = WeatherViewModel()

    // MARK: - User Information

    private var displayName: String? {

        let name = user.displayName?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let name, !name.isEmpty {
            return name
        }

        if let email = user.email,
           let firstPart = email.components(separatedBy: "@").first,
           !firstPart.isEmpty {
            return firstPart
        }

        return nil
    }

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(alignment: .leading, spacing: 24) {

                    // MARK: Greeting

                    HStack {

                        VStack(alignment: .leading, spacing: 5) {

                            HStack(spacing: 5) {

                                Text("home.greeting")
                                    .font(.title2.bold())
                                    .foregroundStyle(PlantDoctorTheme.text)

                                if let displayName {

                                    Text(displayName)
                                        .font(.title2.bold())
                                        .foregroundStyle(PlantDoctorTheme.green)

                                } else {

                                    Text("home.default_name")
                                        .font(.title2.bold())
                                        .foregroundStyle(PlantDoctorTheme.green)
                                }

                                Text("👋")
                            }

                            Text("home.subtitle")
                                .font(.subheadline)
                                .foregroundStyle(PlantDoctorTheme.secondary)
                        }

                        Spacer()

                        // Animated growing plant

                        PlantGrowthAnimation()
                    }

                    // MARK: Main Banner

                    VStack(alignment: .leading, spacing: 15) {

                        Label(
                            "home.brand",
                            systemImage: "leaf.fill"
                        )
                        .font(.caption.bold())
                        .tracking(2)
                        .foregroundStyle(PlantDoctorTheme.green)

                        Text("home.banner_title")
                            .font(.title2.bold())
                            .foregroundStyle(PlantDoctorTheme.text)

                        Text("home.banner_description")
                            .font(.subheadline)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                            .lineSpacing(4)

                        NavigationLink {
                            PlantDetectionView()
                        } label: {

                            HStack {

                                Spacer()

                                Text("home.analyze")

                                Image(systemName: "arrow.right")

                                Spacer()
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .background(PlantDoctorTheme.green)
                            .clipShape(
                                RoundedRectangle(cornerRadius: 15)
                            )
                        }
                    }
                    .padding(20)
                    .background(PlantDoctorTheme.softGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 25))

                    // MARK: Weather Section

                    WeatherCard(viewModel: weatherViewModel)

                    // MARK: Explore Section

                    Text("home.explore")
                        .font(.title3.bold())
                        .foregroundStyle(PlantDoctorTheme.text)

                    NavigationLink {

                        PlantDetectionView()

                    } label: {

                        HomeFeatureCard(
                            icon: "camera.macro",
                            title: "home.smart_diagnosis",
                            subtitle: "home.smart_diagnosis_description"
                        )
                    }
                    .buttonStyle(.plain)

                    NavigationLink {

                        HistoryView()

                    } label: {

                        HomeFeatureCard(
                            icon: "clock.arrow.circlepath",
                            title: "home.history",
                            subtitle: "home.history_description"
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .background(PlantDoctorTheme.background)
            .toolbar(.hidden, for: .navigationBar)

            // MARK: Google Mobile Ads Banner

            .safeAreaInset(edge: .bottom, spacing: 0) {

                BannerAdView()
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(PlantDoctorTheme.background)
            }

            // MARK: Request Location

            .task {
                weatherViewModel.requestLocation()
            }
        }
    }
}

// MARK: - Weather Card

struct WeatherCard: View {

    @ObservedObject var viewModel: WeatherViewModel

    var body: some View {

        VStack(alignment: .leading, spacing: 16) {

            // MARK: Header

            HStack {

                Label(
                    "weather.title",
                    systemImage: "cloud.sun.fill"
                )
                .font(.headline)
                .foregroundStyle(PlantDoctorTheme.text)

                Spacer()

                if let cityName = viewModel.cityName,
                   cityName != "weather.city_unknown" {

                    Text(cityName)
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)

                } else if viewModel.hasError {

                    Text("weather.city_unknown")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)

                } else {

                    Text("weather.city_loading")
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)
                }

                Button {
                    viewModel.refreshWeather()
                } label: {

                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(PlantDoctorTheme.green)
                }
                .disabled(viewModel.isLoading)
                .accessibilityLabel("weather.refresh")
            }

            // MARK: Loading State

            if viewModel.isLoading && viewModel.snapshot == nil {

                HStack {

                    ProgressView()

                    Text("weather.loading")
                        .font(.subheadline)
                        .foregroundStyle(PlantDoctorTheme.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)

            // MARK: Weather Data

            } else if let weather = viewModel.snapshot {

                HStack(spacing: 15) {

                    // Animated weather icon

                    WeatherAnimationView(
                        weatherCode: weather.weatherCode
                    )
                    .frame(width: 65, height: 60)

                    VStack(alignment: .leading, spacing: 4) {

                        Text("\(Int(weather.temperature.rounded()))°C")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(PlantDoctorTheme.text)

                        Text(LocalizedStringKey(weather.conditionKey))
                            .font(.subheadline)
                            .foregroundStyle(PlantDoctorTheme.secondary)
                    }

                    Spacer()
                }

                // MARK: Weather Details

                HStack {

                    Label(
                        "\(weather.humidity)%",
                        systemImage: "humidity.fill"
                    )

                    Spacer()

                    Label(
                        "\(Int(weather.windSpeed.rounded())) km/h",
                        systemImage: "wind"
                    )
                }
                .font(.caption)
                .foregroundStyle(PlantDoctorTheme.secondary)

                Divider()

                // MARK: Plant Advice

                VStack(alignment: .leading, spacing: 6) {

                    Label(
                        "weather.plant_advice",
                        systemImage: "leaf.fill"
                    )
                    .font(.subheadline.bold())
                    .foregroundStyle(PlantDoctorTheme.green)

                    Text(LocalizedStringKey(weather.adviceKey))
                        .font(.caption)
                        .foregroundStyle(PlantDoctorTheme.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if viewModel.isLoading {

                    ProgressView()
                        .tint(PlantDoctorTheme.green)
                }

            // MARK: Error State

            } else if viewModel.hasError {

                VStack(alignment: .leading, spacing: 10) {

                    Text("weather.error")
                        .font(.subheadline)
                        .foregroundStyle(PlantDoctorTheme.secondary)

                    Button("weather.retry") {
                        viewModel.refreshWeather()
                    }
                    .foregroundStyle(PlantDoctorTheme.green)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 10)

            } else {

                Text("weather.no_data")
                    .font(.subheadline)
                    .foregroundStyle(PlantDoctorTheme.secondary)
            }
        }
        .padding(18)
        .background(PlantDoctorTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay {

            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    PlantDoctorTheme.border,
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Home Feature Card

struct HomeFeatureCard: View {

    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {

        HStack(spacing: 15) {

            Image(systemName: icon)
                .font(.system(size: 25))
                .foregroundStyle(PlantDoctorTheme.green)
                .frame(width: 55, height: 55)
                .background(PlantDoctorTheme.softGreen)
                .clipShape(RoundedRectangle(cornerRadius: 15))

            VStack(alignment: .leading, spacing: 5) {

                Text(title)
                    .font(.headline)
                    .foregroundStyle(PlantDoctorTheme.text)

                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(PlantDoctorTheme.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(PlantDoctorTheme.green)
        }
        .padding()
        .background(PlantDoctorTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {

            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    PlantDoctorTheme.border,
                    lineWidth: 1
                )
        }
    }
}

// MARK: - Animated Growing Plant

struct PlantGrowthAnimation: View {

    @State private var hasGrown = false
    @State private var isSwaying = false

    var body: some View {

        ZStack(alignment: .bottom) {

            // Plant stem

            Capsule()
                .fill(PlantDoctorTheme.green)
                .frame(
                    width: 4,
                    height: hasGrown ? 27 : 0
                )
                .offset(y: -13)

            // Left leaf

            Image(systemName: "leaf.fill")
                .font(.system(size: 23))
                .foregroundStyle(PlantDoctorTheme.green)
                .rotationEffect(
                    .degrees(isSwaying ? -25 : -42)
                )
                .scaleEffect(hasGrown ? 1 : 0.1)
                .offset(x: -10, y: -23)

            // Right leaf

            Image(systemName: "leaf.fill")
                .font(.system(size: 23))
                .foregroundStyle(
                    Color(
                        red: 0.40,
                        green: 0.67,
                        blue: 0.30
                    )
                )
                .rotationEffect(
                    .degrees(isSwaying ? 25 : 42)
                )
                .scaleEffect(hasGrown ? 1 : 0.1)
                .offset(x: 10, y: -34)

            // Plant pot

            Image(systemName: "flowerpot.fill")
                .font(.system(size: 30))
                .foregroundStyle(PlantDoctorTheme.green)
                .offset(y: 2)
        }
        .frame(width: 65, height: 65)
        .scaleEffect(hasGrown ? 1 : 0.65)
        .onAppear {

            withAnimation(
                .spring(
                    response: 0.9,
                    dampingFraction: 0.65
                )
            ) {
                hasGrown = true
            }

            withAnimation(
                .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                isSwaying = true
            }
        }
        .accessibilityLabel("Growing plant animation")
    }
}

// MARK: - Dynamic Weather Animation

struct WeatherAnimationView: View {

    let weatherCode: Int

    @State private var isAnimating = false

    // MARK: Weather Icon

    private var weatherIcon: String {

        switch weatherCode {

        case 0:
            return "sun.max.fill"

        case 1, 2:
            return "cloud.sun.fill"

        case 3:
            return "cloud.fill"

        case 45, 48:
            return "cloud.fog.fill"

        case 51...67:
            return "cloud.drizzle.fill"

        case 71...77, 85, 86:
            return "snowflake"

        case 80...82:
            return "cloud.heavyrain.fill"

        case 95...99:
            return "cloud.bolt.rain.fill"

        default:
            return "cloud.sun.fill"
        }
    }

    // MARK: Weather Conditions

    private var isSunny: Bool {
        weatherCode == 0
    }

    private var isStormy: Bool {
        (95...99).contains(weatherCode)
    }

    private var isRainy: Bool {
        (51...67).contains(weatherCode) ||
        (80...82).contains(weatherCode)
    }

    private var isSnowy: Bool {
        (71...77).contains(weatherCode) ||
        weatherCode == 85 ||
        weatherCode == 86
    }

    // MARK: Animation

    var body: some View {

        Image(systemName: weatherIcon)
            .font(.system(size: 43))
            .foregroundStyle(
                isStormy
                ? Color.orange
                : PlantDoctorTheme.green
            )
            .rotationEffect(
                .degrees(
                    isSunny && isAnimating ? 15 :
                    isSnowy && isAnimating ? 180 : 0
                )
            )
            .offset(
                x: isAnimating && !isSunny ? 5 : 0,
                y: isAnimating ? -3 : 3
            )
            .scaleEffect(
                isAnimating && isStormy ? 1.12 : 1
            )
            .animation(
                .easeInOut(
                    duration: isStormy ? 0.45 : 1.5
                )
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
            .accessibilityLabel("Weather animation")
    }
}
