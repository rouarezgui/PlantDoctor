//
//  WeatherService.swift
//  PlanDoctor
//
//  Created by azertt on 23/11/2026.
//

import Foundation
import Combine
import CoreLocation

// MARK: - Weather Model

struct WeatherSnapshot {

    let temperature: Double
    let humidity: Int
    let windSpeed: Double
    let weatherCode: Int

    // MARK: Weather Condition

    var conditionKey: String {
        switch weatherCode {
        case 0:
            return "weather.condition.clear"

        case 1, 2:
            return "weather.condition.partly_cloudy"

        case 3:
            return "weather.condition.cloudy"

        case 45, 48:
            return "weather.condition.fog"

        case 51, 53, 55, 56, 57:
            return "weather.condition.drizzle"

        case 61, 63, 65, 66, 67:
            return "weather.condition.rain"

        case 71, 73, 75, 77, 85, 86:
            return "weather.condition.snow"

        case 80, 81, 82:
            return "weather.condition.showers"

        case 95, 96, 99:
            return "weather.condition.storm"

        default:
            return "weather.condition.unknown"
        }
    }

    // MARK: Plant Advice

    var adviceKey: String {

        if weatherCode >= 95 {
            return "weather.advice.storm"
        }

        if (51...82).contains(weatherCode) {
            return "weather.advice.rain"
        }

        if temperature >= 32 {
            return "weather.advice.hot"
        }

        if humidity < 35 {
            return "weather.advice.dry"
        }

        if humidity > 80 {
            return "weather.advice.humid"
        }

        return "weather.advice.normal"
    }
}

// MARK: - Open-Meteo API Response

private struct OpenMeteoResponse: Decodable {

    let current: CurrentWeather

    struct CurrentWeather: Decodable {

        let temperature2m: Double
        let relativeHumidity2m: Int
        let windSpeed10m: Double
        let weatherCode: Int

        enum CodingKeys: String, CodingKey {

            case temperature2m = "temperature_2m"
            case relativeHumidity2m = "relative_humidity_2m"
            case windSpeed10m = "wind_speed_10m"
            case weatherCode = "weather_code"
        }
    }
}

// MARK: - Weather Service

struct WeatherService {

    func fetchWeather(
        latitude: Double,
        longitude: Double
    ) async throws -> WeatherSnapshot {

        guard var components = URLComponents(
            string: "https://api.open-meteo.com/v1/forecast"
        ) else {
            throw URLError(.badURL)
        }

        components.queryItems = [

            URLQueryItem(
                name: "latitude",
                value: String(latitude)
            ),

            URLQueryItem(
                name: "longitude",
                value: String(longitude)
            ),

            URLQueryItem(
                name: "current",
                value: "temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code"
            ),

            URLQueryItem(
                name: "timezone",
                value: "auto"
            ),

            URLQueryItem(
                name: "wind_speed_unit",
                value: "kmh"
            )
        ]

        guard let url = components.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let result = try JSONDecoder().decode(
            OpenMeteoResponse.self,
            from: data
        )

        return WeatherSnapshot(
            temperature: result.current.temperature2m,
            humidity: result.current.relativeHumidity2m,
            windSpeed: result.current.windSpeed10m,
            weatherCode: result.current.weatherCode
        )
    }
}

// MARK: - Weather View Model

@MainActor
final class WeatherViewModel: ObservableObject {

    // MARK: Published Properties

    @Published var snapshot: WeatherSnapshot?
    @Published var isLoading = false
    @Published var hasError = false
    @Published var cityName: String?

    // MARK: Services

    private let service = WeatherService()
    private let locationService = LocationService()
    private let geocoder = CLGeocoder()

    private var coordinateSubscription: AnyCancellable?
    private var locationErrorSubscription: AnyCancellable?

    // MARK: Initialization

    init() {

        // Observe GPS coordinates.

        coordinateSubscription = locationService.$coordinate
            .compactMap { $0 }
            .sink { [weak self] coordinate in

                guard let self else { return }

                Task { @MainActor in
                    await self.fetchWeather(for: coordinate)
                }
            }

        // Observe location errors.

        locationErrorSubscription = locationService.$locationError
            .compactMap { $0 }
            .sink { [weak self] error in

                guard let self else { return }

                self.hasError = true
                self.isLoading = false

                print("Location error:", error)
            }
    }

    // MARK: Request GPS Location

    func requestLocation() {

        hasError = false

        locationService.requestLocation()
    }

    // MARK: Refresh Weather

    func refreshWeather() {

        hasError = false
        isLoading = true

        // Request a fresh GPS position.
        locationService.requestLocation()
    }

    // MARK: Fetch Weather

    private func fetchWeather(
        for coordinate: CLLocationCoordinate2D
    ) async {

        isLoading = true
        hasError = false

        defer {
            isLoading = false
        }

        do {

            // 1. Fetch weather using real GPS coordinates.

            let weather = try await service.fetchWeather(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )

            snapshot = weather

            print("GPS latitude:", coordinate.latitude)
            print("GPS longitude:", coordinate.longitude)

            // 2. Convert GPS coordinates into a city name.

            let location = CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude
            )

            let placemarks = try await geocoder.reverseGeocodeLocation(
                location
            )

            guard let placemark = placemarks.first else {

                cityName = "weather.city_unknown"

                print("No placemark found.")

                return
            }

            // 3. Display location information in Xcode console.

            print("LOCALITY:", placemark.locality ?? "nil")
            print("SUBLOCALITY:", placemark.subLocality ?? "nil")
            print(
                "SUBADMINISTRATIVE:",
                placemark.subAdministrativeArea ?? "nil"
            )
            print(
                "ADMINISTRATIVE:",
                placemark.administrativeArea ?? "nil"
            )
            print("COUNTRY:", placemark.country ?? "nil")

            // 4. Select the appropriate city name.

            if placemark.isoCountryCode == "TN" {

                // Prefer the Tunisian governorate.
                cityName = placemark.administrativeArea
                    ?? placemark.locality
                    ?? placemark.subAdministrativeArea
                    ?? "weather.city_unknown"

            } else {

                // Prefer the city for other countries.
                cityName = placemark.locality
                    ?? placemark.subAdministrativeArea
                    ?? placemark.administrativeArea
                    ?? "weather.city_unknown"
            }

            print("Detected city:", cityName ?? "Unknown")

        } catch {

            hasError = true

            print(
                "Weather or geocoding error:",
                error.localizedDescription
            )
        }
    }
}
