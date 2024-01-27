//
//  AppDelegate.swift
//  CubeScene
//
//  Created by yanguo sun on 2024/1/24.
//

import Foundation
import UIKit
import RevenueCat

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        // 执行应用程序启动时的操作 RevenueCat
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_lNBhYAAESbCcENhLTzCZUYXgoHU")
           Purchases.shared.delegate = self // make sure to set this after calling configure
        // Using Completion Blocks
        Purchases.shared.getProducts(["6450415992001"]) { stlist in
            print("\(stlist)")
        }
        Purchases.shared.getOfferings(completion: { offers, err in
            print("\(String(describing: offers))")
        })
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if customerInfo?.entitlements.all["soma_t"]?.isActive == true {
                // User is "premium"f
                print("\(String(describing: customerInfo))")
            }
            //print("\(String(describing: customerInfo))")
        }
        return true
    }
}

extension AppDelegate: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        /// - handle any changes to the user's CustomerInfo
    }
}
