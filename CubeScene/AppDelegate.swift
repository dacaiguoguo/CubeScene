//
//  AppDelegate.swift
//  CubeScene
//
//  Created by yanguo sun on 2024/1/24.
//

import Foundation
import UIKit
import RevenueCat


class SubscriptionManager {
    static let shared = SubscriptionManager() // 使用单例模式

    var isPremiumUser: Bool = false {
        didSet {
            // 每当isPremiumUser的值改变时，持久化该值
            UserDefaults.standard.set(isPremiumUser, forKey: "isPremiumUser")
        }
    }

    init() {
        // 从UserDefaults读取之前持久化的订阅状态
        isPremiumUser = UserDefaults.standard.bool(forKey: "isPremiumUser")
    }

    func checkSubscriptionStatus() {
        Purchases.shared.getCustomerInfo { (customerInfo, error) in
            if let error = error {
                print("Failed to retrieve customer info: \(error.localizedDescription)")
                return
            }

            if customerInfo?.entitlements.all["soma_t"]?.isActive == true {
                // 用户是"premium"用户
                self.isPremiumUser = true
                print("User is premium")
            } else {
                // 用户不是"premium"用户
                self.isPremiumUser = false
                print("User is not premium")
            }
        }
    }
}


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
                // 存储到某个变量 并持久化
                SubscriptionManager.shared.isPremiumUser = true;
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
