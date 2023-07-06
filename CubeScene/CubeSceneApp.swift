//
//  CubeSceneApp.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
//

import SwiftUI


@main
struct CubeSceneApp: App {
    
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

   
    var body: some Scene {
        WindowGroup {
            NavigationView {
                EnterListView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading: helpButton(), trailing:showButton()
                    )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
