//
//  CubeSceneApp.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
// 自定义修改颜色，和默认配色
// 1.增加按钮 标记已经玩过。完成
// 国际化 部分完成
// TODO: EnterListView 入口优化为图片
// TODO: 增加240种演示动画
// TODO: 增加难度星级标识和筛选
// TODO: 增加单步骤动画
// TODO: 限制x轴旋转角度 防止翻转 增加恢复位置按钮
// TODO: 分为3个tab，第一个108种，第二个立方体的240种解法，第三个创意玩法，第四个我的（设置，关于入口）
// ;https://www.fam-bundgaard.dk/SOMA/FIGURES/T101125.HTM

import SwiftUI
import UIKit



// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print(">> your code here !!")
        return true
    }
}

@main
struct CubeSceneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase
    
    let userData = UserData()
    //    init() {
    //        print("init app\(demo.orderList())")
    //
    //    }
    //   @State var demo = EnterItem(name: "测试", matrix: [[[2,4,3], [6,4,1], [6,6,1]],
    //                                                    [[2,3,3], [6,4,1], [7,4,5]],
    //                                                    [[2,2,3], [7,5,5], [7,7,5]]], usedBlock: [1,2,3,4,5,6,7], isTaskComplete: true)
    var body: some Scene {
        WindowGroup {
            //            NavigationView {
            //                SingleContentView(dataModel:$demo, showColor: [])
            //                .environmentObject(userData)
            //                .navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
            //
            //            }
            //            .navigationViewStyle(StackNavigationViewStyle())
            TabView {
                NavigationView {
                    EnterListView(productList: produceData(resourceName: "data3")).navigationTitle("TitleName").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            print("onAppear EnterListView !")
                        }.environmentObject(userData)
                }
                .navigationViewStyle(StackNavigationViewStyle()).tabItem {
                    Image(systemName: "cube")
                    Text("TabTitleName")
                }.tag(0)
                
                NavigationView {
                    EnterListView240().environmentObject(userData)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("TitleName2")
                }
                .navigationViewStyle(StackNavigationViewStyle()).tabItem {
                    Image(systemName: "cube.transparent")
                    Text("TabTitleName2")
                }.tag(1)
                NavigationView {
                    EnterListView(productList: produceData(resourceName: "SOMAT101")).navigationTitle("TitleName3").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            print("onAppear EnterListView !")
                        }.environmentObject(userData)
                }
                .navigationViewStyle(StackNavigationViewStyle()).tabItem {
                    Image(systemName: "scribble.variable")
                    Text("TabTitleName3")
                }.tag(2)
                NavigationView {
                    SettingView().environmentObject(userData)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("TitleName4")
                }.navigationViewStyle(StackNavigationViewStyle()).tabItem {
                    Image(systemName: "cube.transparent")
                    Text("TabTitleName4")
                }.tag(3)
            }
            
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
