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
                NavigationView {
                    ContentView().navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}
