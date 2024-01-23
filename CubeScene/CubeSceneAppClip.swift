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

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

@main
struct CubeSceneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    let userData = UserData()

    var body: some Scene {
        WindowGroup {
            TabView {
                tabFor108()
                tabFor240()
                tabForT()
                tabForTry()
                tabForMore()
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
            enterListView(with: "SOMAT101", title: "TitleName3")
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
        // 执行应用程序启动时的操作        
    }
}

