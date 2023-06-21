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
            NavigationStack {
                ZStack{
                    Image("wenli")
                        .resizable(resizingMode: .tile)
                    ContentView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}
