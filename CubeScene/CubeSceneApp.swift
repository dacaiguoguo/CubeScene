//
//  CubeSceneApp.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
//

import SwiftUI


@main
struct CubeSceneApp: App {
    @State private var isPresented = false

    func showButton() -> some View {
        Button(action: {
            // 执行按钮1的操作
            isPresented = true
        },label:  {
            Image(systemName: "gear.circle")
        })
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                EnterListView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing:showButton()
                    ) .sheet(isPresented: $isPresented, content: { SettingView() })
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
