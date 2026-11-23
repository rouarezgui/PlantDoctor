//
//  BannerAdView.swift
//  PlanDoctor
//
//  Created by azertt on 23/11/2026.
//

import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {

    // Identifiant de test Google : bannière iPhone
    private let adUnitID = "ca-app-pub-3940256099942544/2934735716"

    func makeUIView(context: Context) -> GADBannerView {

        let banner = GADBannerView(adSize: GADAdSizeBanner)

        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController

        banner.load(GADRequest())

        return banner
    }

    func updateUIView(
        _ uiView: GADBannerView,
        context: Context
    ) {
        // Aucune mise à jour nécessaire.
    }
}
