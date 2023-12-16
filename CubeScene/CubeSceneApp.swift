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

import SceneKit
struct ContentView2: View {
    var scene:SCNScene {
        let ret =  SCNScene(named: "cube2.scn")!
        // 创建光源
        let light = SCNLight()
        light.type = .omni // 或者使用 .directional
        light.intensity = 1000.0 // 光强度
        light.color = UIColor.white // 漫反射颜色
        
        // 创建光源节点
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 5, z: 5) // 光源位置
        ret.rootNode.addChildNode(lightNode)
        return ret;
    }
    
    
    //    allowsCameraControl
    var cameraNode: SCNNode? {
        let ret = scene.rootNode.childNode(withName: "Camera", recursively: false)
        return ret;
    }
    
    var body: some View {
        SceneView(
            scene: scene,
            pointOfView: cameraNode,
            options: [.allowsCameraControl]
        )
    }
}

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
    let result = transMatrix(with:
                                //                                [[[2,4,3], [6,4,1], [6,6,1]],
                             //                                 [[2,3,3], [6,4,1], [7,4,5]],
                             //                                 [[2,2,3], [7,5,5], [7,7,5]]]
                             [[[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],
                              [[-1, 2, 2], [-1, 2, -1], [-1, 2, -1]],
                              [[-1, -1, -1], [-1, -1, -1], [-1, -1, -1]],]
    )
    //    init() {
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
                    EnterListView(productList: produceData(resourceName: "SOMA108")).navigationTitle("TitleName").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
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
                            
                        }.environmentObject(userData)
                }
                .navigationViewStyle(StackNavigationViewStyle()).tabItem {
                    Image(systemName: "scribble.variable")
                    Text("TabTitleName3")
                }.tag(2)
                NavigationView {
                    ContentView2().navigationTitle("TabTitleNameY").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
                        }.environmentObject(userData)
                }
                .navigationViewStyle(StackNavigationViewStyle()).tabItem {
                    Image(systemName: "highlighter")
                    Text("TabTitleNameY")
                }.tag(3)
                
                NavigationView {
                    SettingView().environmentObject(userData)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle("TitleName4")
                }.navigationViewStyle(StackNavigationViewStyle()).tabItem {
                    Image(systemName: "ellipsis.circle")
                    Text("TabTitleName4")
                }.tag(4)
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
        // ...
    }
}
