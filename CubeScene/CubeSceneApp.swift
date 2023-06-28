//
//  CubeSceneApp.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
//

import SwiftUI

@main
struct CubeSceneApp: App {
    var body: some Scene {
        WindowGroup {
            if #available(iOS 16.0, *) {
                NavigationStack {
                    ContentView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                }
            } else {
                TabView {
                    NavigationView {
                        ContentView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                    }.tabItem {
                        Image(systemName: "gamecontroller")
                        Text("练习")
                    }.tag(0)
                    NavigationView {
                        ContentView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                    }.tabItem {
                        Image(systemName: "scribble.variable")
                        Text("自定义")
                    }.tag(0)
                    NavigationView {
                        SettingView().navigationTitle("设置").navigationBarTitleDisplayMode(.inline)
                    }.tabItem {
                        Image(systemName: "gear.circle")
                        Text("设置")
                    }.tag(0)
                }
            }
        }
    }
}
