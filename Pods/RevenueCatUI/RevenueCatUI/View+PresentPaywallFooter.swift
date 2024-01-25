//
//  Copyright RevenueCat Inc. All Rights Reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://opensource.org/licenses/MIT
//
//  View+PresentPaywallFooter.swift
//
//  Created by Josh Holtz on 8/18/23.

import RevenueCat
import SwiftUI

#if !os(watchOS) && !os(tvOS) && !os(macOS)

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
extension View {

    /// Presents a ``PaywallFooterView`` at the bottom of a view that loads the `Offerings.current`.
    /// ```swift
    /// var body: some View {
    ///    YourPaywall()
    ///      .paywallFooter()
    /// }
    /// ```
    ///
    /// ### Related Articles
    /// [Documentation](https://rev.cat/paywalls)
    public func paywallFooter(
        condensed: Bool = false,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider(),
        purchaseCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        restoreCompleted: PurchaseOrRestoreCompletedHandler? = nil
    ) -> some View {
        return self.paywallFooter(
            offering: nil,
            customerInfo: nil,
            condensed: condensed,
            fonts: fonts,
            introEligibility: nil,
            purchaseCompleted: purchaseCompleted,
            restoreCompleted: restoreCompleted
        )
    }

    /// Presents a ``PaywallFooterView`` at the bottom of a view with the given offering.
    /// ```swift
    /// var body: some View {
    ///    YourPaywall()
    ///      .paywallFooter(offering: offering)
    /// }
    /// ```
    ///
    /// ### Related Articles
    /// [Documentation](https://rev.cat/paywalls)
    public func paywallFooter(
        offering: Offering,
        condensed: Bool = false,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider(),
        purchaseCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        restoreCompleted: PurchaseOrRestoreCompletedHandler? = nil
    ) -> some View {
        return self.paywallFooter(
            offering: offering,
            customerInfo: nil,
            condensed: condensed,
            fonts: fonts,
            introEligibility: nil,
            purchaseCompleted: purchaseCompleted,
            restoreCompleted: restoreCompleted
        )
    }

    func paywallFooter(
        offering: Offering?,
        customerInfo: CustomerInfo?,
        condensed: Bool = false,
        fonts: PaywallFontProvider = DefaultPaywallFontProvider(),
        introEligibility: TrialOrIntroEligibilityChecker? = nil,
        purchaseHandler: PurchaseHandler? = nil,
        purchaseCompleted: PurchaseOrRestoreCompletedHandler? = nil,
        restoreCompleted: PurchaseOrRestoreCompletedHandler? = nil
    ) -> some View {
        return self
            .modifier(
                PresentingPaywallFooterModifier(
                    configuration: .init(
                        content: .optionalOffering(offering),
                        customerInfo: customerInfo,
                        mode: condensed ? .condensedFooter : .footer,
                        fonts: fonts,
                        displayCloseButton: false,
                        introEligibility: introEligibility,
                        purchaseHandler: purchaseHandler
                    ),
                    purchaseCompleted: purchaseCompleted,
                    restoreCompleted: restoreCompleted
                )
            )
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
private struct PresentingPaywallFooterModifier: ViewModifier {

    let configuration: PaywallViewConfiguration
    let purchaseCompleted: PurchaseOrRestoreCompletedHandler?
    let restoreCompleted: PurchaseOrRestoreCompletedHandler?

    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom) {
                PaywallView(configuration: self.configuration)
                .onPurchaseCompleted {
                    self.purchaseCompleted?($0)
                }
                .onRestoreCompleted {
                    self.restoreCompleted?($0)
                }
        }
    }
}

#endif