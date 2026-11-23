//
//  InterstitialAdManager.swift
//  PlanDoctor
//
//  Created by azertt on 23/11/2026.
//

import Foundation
import UIKit
import GoogleMobileAds

final class InterstitialAdManager: NSObject, ObservableObject, GADFullScreenContentDelegate {

    // Identifiant officiel Google : publicité interstitielle de test
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"

    private var interstitial: GADInterstitialAd?
    private var onDismiss: (() -> Void)?

    override init() {
        super.init()
        loadAd()
    }

    // MARK: - Load Interstitial Ad

    func loadAd() {
        let request = GADRequest()

        GADInterstitialAd.load(
            withAdUnitID: adUnitID,
            request: request
        ) { [weak self] ad, error in

            guard let self = self else { return }

            if let error = error {
                print("❌ Interstitial loading error: \(error.localizedDescription)")
                self.interstitial = nil
                return
            }

            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self

            print("✅ Interstitial ad loaded successfully")
        }
    }

    // MARK: - Show Interstitial Ad

    func showAd(completion: @escaping () -> Void) {

        guard let interstitial = interstitial else {
            print("⚠️ Interstitial not ready")
            completion()
            loadAd()
            return
        }

        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let rootViewController = windowScene.windows
            .first(where: { $0.isKeyWindow })?.rootViewController else {

            print("❌ Root view controller not found")
            completion()
            return
        }

        // Remonter jusqu'au contrôleur réellement visible
        var topController = rootViewController

        while let presented = topController.presentedViewController {
            topController = presented
        }

        guard topController.viewIfLoaded?.window != nil else {
            print("❌ No active presentation controller")
            completion()
            return
        }

        onDismiss = completion

        DispatchQueue.main.async {
            interstitial.present(fromRootViewController: topController)
        }
    }

    // MARK: - Full Screen Delegate

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("✅ Interstitial dismissed")

        interstitial = nil

        let completion = onDismiss
        onDismiss = nil

        completion?()
        loadAd()
    }

    func ad(
        _ ad: GADFullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("❌ Interstitial presentation error: \(error.localizedDescription)")

        interstitial = nil

        let completion = onDismiss
        onDismiss = nil

        completion?()
        loadAd()
    }
}
