//
//  AppDelegate.swift
//  CubeScene
//
//  Created by yanguo sun on 2024/1/24.
//

import Foundation
import UIKit
import RevenueCat
import Mixpanel
import StoreKit

/// 每次启动个只弹出一次请求评分
var runOnceRequestReview: () = {
    #if targetEnvironment(simulator)
    #else
    SKStoreReviewController.requestReview()
    #endif
    // 在这里写只需执行一次的代码
    
}()
//请求用户授权推送
func requestNotificationAuthorization() {
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
        if granted {
            print("用户已授权本地通知")
            // 创建每天晚上7点触发的本地推送 UNMutableNotificationContent如何设置每周六上午8点发通知
            let content = UNMutableNotificationContent()
            content.title = "Play with your soma"
            content.body = "Don't leave your soma alone. Have a try?"
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.weekday = 7
            dateComponents.hour = 9 // 晚上7点
            dateComponents.minute = 0
            dateComponents.second = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: "somaWeeklyNotification", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("添加成功")
                }
            }
            
        } else {
            print("用户拒绝授权本地通知")
        }
    }
}


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

    func checkSubscriptionStatus2() {
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
        print("Your code here:\(NSHomeDirectory())")
        // 执行应用程序启动时的操作 RevenueCat
        Purchases.configure(withAPIKey: "appl_lNBhYAAESbCcENhLTzCZUYXgoHU")

        // 移除 List 默认的分隔线（如果你想要的话）
        UITableView.appearance().separatorStyle = .none
        // Replace with your Project Token
        if Purchases.shared.isAtSandbox {
            // 初始化 Mixpanel
            Mixpanel.initialize(token: "519f100127827f64d9df5052b8dc0e92", trackAutomaticEvents: true)
            print("Purchases.shared.isAtSandbox true")
        } else {
            print("Purchases.shared.isAtSandbox false")
            Mixpanel.initialize(token: "0db8c0bbc4140bee54384c6d148e9270", trackAutomaticEvents: true)
        }
 
        
        Mixpanel.mainInstance().track(event: "Signed Up", properties: [
            "Signup Type": "Referral",
        ])
#if DEBUG
        Purchases.logLevel = .debug
#endif
        
        // Option 2: Set different Mixpanel identifier in RevenueCat
        
        
        
        Purchases.shared.delegate = self // make sure to set this after calling configure
        Purchases.shared.attribution.setMixpanelDistinctID(Mixpanel.mainInstance().distinctId)

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
        requestNotificationAuthorization()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            // 评分弹窗
            _ = runOnceRequestReview
        }
        SubscriptionManager.shared.checkSubscriptionStatus2()
        return true
    }
}

extension AppDelegate: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        /// - handle any changes to the user's CustomerInfo
         if customerInfo.entitlements.all["soma_t"]?.isActive == true {
        // User is "premium"f
        // 存储到某个变量 并持久化
        SubscriptionManager.shared.isPremiumUser = true;
        print("\(String(describing: customerInfo))")
    }
    }
}
