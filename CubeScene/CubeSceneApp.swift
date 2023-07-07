//
//  CubeSceneApp.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
// TODO: 自定义修改颜色，和默认配色
// 1.增加按钮 标记已经玩过。

import SwiftUI
import UIKit



// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print(">> your code here !!")
        let array = [UIColor(hex: "000000"),
                     UIColor(hex: "FF8800"),
                     UIColor(hex: "0396FF"),
                     UIColor(hex: "EA5455"),
                     UIColor(hex: "7367F0"),
                     UIColor.gray,
                     UIColor(hex: "28C76F"),
                     UIColor.purple];

        for (index, item) in array.enumerated() {
            UserDefaults.standard.register(defaults: ["block\(index)" : item.encode()!])
        }

        let naturalNumbers = Array(0...6)
        naturalNumbers.forEach { index in
            if let data = UserDefaults.standard.object(forKey: "block\(index)") {
                print(UIColor.decode(data: data as! Data))
            }
        }
        return true
    }
}

@main
struct CubeSceneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase

    func showButton() -> some View {
        NavigationLink {
            SettingView()
        } label: {
            Image(systemName: "info.circle")
        }
    }
    
    func helpButton() -> some View {
        NavigationLink {
            ConfigView()
        } label: {
            Image(systemName: "gear.circle")
        }
    }

    init() {
        print("init app")
    }
    var body: some Scene {
        WindowGroup {
            NavigationView {
                EnterListView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading: helpButton(), trailing:showButton()
                    ).onAppear {
                        print("onAppear EnterListView !")
                    }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }.onChange(of: scenePhase) { phase in
            if phase == .active {
                // Perform launch tasks
                performLaunchTasks()
            }
        }
    }

    func performLaunchTasks() {
        // 执行应用程序启动时的操作
        print("App performLaunchTasks!")
        // ...
    }
}
