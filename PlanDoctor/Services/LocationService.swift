//
//  LocationService.swift
//  PlanDoctor
//
//  Created by azertt on 23/11/2026.
//

import Foundation
import CoreLocation
import Combine

@MainActor
final class LocationService: NSObject, ObservableObject {

    // MARK: - Published Properties

    @Published var coordinate: CLLocationCoordinate2D?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var locationError: String?

    // MARK: - Location Manager

    private let manager = CLLocationManager()

    // MARK: - Initialization

    override init() {
        authorizationStatus = manager.authorizationStatus

        super.init()

        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    // MARK: - Request Location

    func requestLocation() {

        locationError = nil

        switch manager.authorizationStatus {

        case .notDetermined:
            // Request permission from the user
            manager.requestWhenInUseAuthorization()

        case .authorizedAlways, .authorizedWhenInUse:
            // Permission already granted
            manager.requestLocation()

        case .denied, .restricted:
            // Permission denied
            locationError = "location.permission_denied"

        @unknown default:
            locationError = "location.unknown_error"
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {

    // MARK: Authorization Changed

    func locationManagerDidChangeAuthorization(
        _ manager: CLLocationManager
    ) {

        authorizationStatus = manager.authorizationStatus

        switch manager.authorizationStatus {

        case .authorizedAlways, .authorizedWhenInUse:
            locationError = nil
            manager.requestLocation()

        case .denied, .restricted:
            locationError = "location.permission_denied"

        case .notDetermined:
            break

        @unknown default:
            locationError = "location.unknown_error"
        }
    }

    // MARK: Location Updated

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let location = locations.last else {
            locationError = "location.unknown_error"
            return
        }

        coordinate = location.coordinate
        locationError = nil
    }

    // MARK: Location Failed

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {

        locationError = "location.unknown_error"

        print("Location error:", error.localizedDescription)
    }
}
