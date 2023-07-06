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
    @State private var help = false
    
    func showButton() -> some View {
        Button(action: {
            // 执行按钮1的操作
            help = false
            isPresented = true
        },label:  {
            Image(systemName: "info.circle")
        })
    }
    
    func helpButton() -> some View {
        Button(action: {
            // 执行按钮1的操作
            help = true
            isPresented = true
        },label:  {
            Image(systemName: "gear.circle")
        })
    }

    func helpOrSettingView() -> some View {
        return NavigationView{
            if help {
                ConfigView()
            } else {
                SettingView()
            }
            
        }
    }
    var body: some Scene {
        WindowGroup {
            NavigationView {
                EnterListView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading: helpButton(), trailing:showButton()
                    ) .sheet(isPresented: $isPresented, content: { helpOrSettingView() })
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
