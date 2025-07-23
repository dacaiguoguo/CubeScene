//
//  CubeSceneApp.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
// 自定义修改颜色，和默认配色
// 1.增加按钮 标记已经玩过。完成
// 国际化 部分完成
// EnterListView 入口优化为图片
// 增加240种演示动画
// TODO: 增加筛选 简单
// 增加单步骤动画 已经增加
// TODO: 限制x轴旋转角度 防止翻转 增加恢复位置按钮 可以不做
// TODO: 同一个形状，添加多种解法 比如A034
// TODO: 增加双套VLTZABP和1234567的支持，显示不同配色
// TODO: 增加自定义动画顺序
// ;https://www.fam-bundgaard.dk/SOMA/FIGURES/T101125.HTM

import SwiftUI
import UIKit
import RevenueCat
import RevenueCatUI
import Mixpanel

class ImageCounter: ObservableObject {
    static let shared = ImageCounter()
    
    @Published var imageCount: Int = 0

    private init() {
        self.imageCount = UserDefaults.standard.integer(forKey: "T")
    }

    /// 读取并增加图片生成计数器
    /// - Parameter key: 存储在 UserDefaults 中的键名
    /// - Returns: 返回增加前的值
    func incrementImageCount(forKey key: String) -> Int {
        let currentCount = UserDefaults.standard.integer(forKey: key)
        let newCount = currentCount + 1
        UserDefaults.standard.set(newCount, forKey: key)
        UserDefaults.standard.synchronize()  // 确保数据被保存到磁盘
        DispatchQueue.main.async {
            self.imageCount = newCount
        }
        return currentCount
    }
}

@main
struct CubeSceneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    let userData = UserData()
    @State private var selectedTab = 0
    @State private var showParentalGate: Bool = false
    @State private var requestedTab: Int?
    @ObservedObject var imageCounter = ImageCounter.shared
    @ObservedObject var subscriptionManager = SubscriptionManager.shared

    var body: some Scene {
        WindowGroup {
            TabView(selection: Binding(get: {
                selectedTab
            }, set: { newTab in
                selectedTab = newTab
                if !SubscriptionManager.shared.isPremiumUser {
                    showParentalGate = true
                }
            })) {
                tabFor108()
                tabFor240()
                tabForT()
                tabForTry()
                tabForMore()
            }
            .fullScreenCover(isPresented: $showParentalGate) {
                ParentalGateView(onCorrectAnswer: {
                    if let requestedTab = requestedTab {
                        selectedTab = requestedTab
                        Mixpanel.mainInstance().track(event: "selectedTab", properties: ["Signup": "\(requestedTab)"])
                    }
                    showParentalGate = false
                })
            }
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                performLaunchTasks()
            }
        }
        
    }
    
    // MARK: - Tabs
    
    func tabFor108() -> some View {
        NavigationView {
            enterListView(with: "SOMA108", title: "TitleName")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Image(systemName: "cube")
            Text("TabTitleName")
        }
        .tag(0)
    }
    
    func tabFor240() -> some View {
        NavigationView {
            EnterListView240().environmentObject(userData)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("TitleName2")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Image(systemName: "cube.transparent")
            Text("TabTitleName2")
        }
        .tag(1)
    }
    
    func tabForT() -> some View {
        NavigationView {
            if subscriptionManager.isPremiumUser {
                enterListView(with: "SOMAT101", title: NSLocalizedString("TitleName3", comment: "Tab title for section 3"))
            } else {
                enterListView(with: "SOMAT101", title: "\(NSLocalizedString("TabTitleName3", comment: "Tab title for section 3")) free(\(max(5 - imageCounter.imageCount, 0)))")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Image(systemName: "scribble.variable")
            Text("TabTitleName3")
        }
        .tag(2)
    }
    
    func tabForTry() -> some View {
        NavigationView {
            singleContentView(with: "data1", title: "TabTitleNameTry")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Image(systemName: "highlighter")
            Text("TabTitleNameTry")
        }
        .tag(3)
    }
    
    func tabForMore() -> some View {
        NavigationView {
            SettingView().environmentObject(userData)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("TitleName4")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .tabItem {
            Image(systemName: "ellipsis.circle")
            Text("TabTitleName4")
        }
        .tag(4)
    }
    
    // MARK: - Shared View Functions
    
    @ViewBuilder
    private func enterListView(with resourceName: String, title: String) -> some View {
        EnterListView(productList: produceData(resourceName: resourceName))
            .navigationTitle(LocalizedStringKey(title))
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(userData)
    }
    
    @ViewBuilder
    private func singleContentView(with dataName: String, title: String) -> some View {
        SingleContentView2(nodeList: makeNode(with: produceData(resourceName: dataName).first!.matrix))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .environmentObject(userData)
    }
    
    
    
    // MARK: - Launch Tasks
    
    private func performLaunchTasks() {
        print("performLaunchTasks completed:")
        Purchases.shared.getCustomerInfo { comp, err in
            SubscriptionManager.shared.isPremiumUser = checkUserSubscriptionStatus(comp)
            print("isPremiumUser: \(SubscriptionManager.shared.isPremiumUser)")
        }
    }
}




func checkUserSubscriptionStatus(_ customerInfo:CustomerInfo?) -> Bool {
    var hasActiveSub = false
    // 检查用户是否拥有有效的订阅
    if let customerInfo = customerInfo, customerInfo.entitlements["soma_t"]?.isActive == true {
        print("User has an active subscription.")
        hasActiveSub = true
    } else {
        print("User does not have an active subscription.")
    }
    return hasActiveSub
}
