//
//  ContentView.swift
//  CubeComplete
//
//  Created by yanguo sun on 2023/7/12.
//

import SwiftUI

import SceneKit

struct ContentView: View {
    var body: some View {
        SceneView(scene: createScene(), options: [.autoenablesDefaultLighting, .allowsCameraControl])
            .frame(width: 300, height: 300)
    }

    func createScene() -> SCNScene {
        let scene = SCNScene()

        // Create a box with chamfered corners
        let boxGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.2)
        let boxNode = SCNNode(geometry: boxGeometry)
        scene.rootNode.addChildNode(boxNode)

        // Create a plane as the background
        let planeGeometry = SCNPlane(width: 10, height: 10)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles.x = -.pi / 2 // Rotate the plane to lie flat on the ground
        planeNode.position.y = -0.5 // Position the plane slightly below the box

        scene.rootNode.addChildNode(planeNode)

        // Add some lighting to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 5, z: 5)
        scene.rootNode.addChildNode(lightNode)

        // Create a fixed camera and add it to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 3)
        cameraNode.eulerAngles = SCNVector3(x: -15 * .pi / 180, y: 0, z: 0) // Set a fixed angle for the camera
        scene.rootNode.addChildNode(cameraNode)

        return scene
    }
}

struct Product {
    var name: String
    var isTaskComplete: Bool
    let level: Int
    mutating func toggleFavorite() {
        isTaskComplete.toggle()
    }
}


struct ProductDetailView: View {
    @Binding var product: Product

    var body: some View {
        VStack {
            // 显示产品详情内容

            Button(action: {
                product.toggleFavorite()
            }) {
                if product.isTaskComplete {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "star")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}


//struct ContentView: View {
//    @State private var productList = [
//        Product(name: "Product 1", isTaskComplete: true, level: 3),
//        Product(name: "Product 2", isTaskComplete: false, level: 4),
//        Product(name: "Product 3", isTaskComplete: true, level: 5),
//    ]
//
//    var body: some View {
//        NavigationView {
//            ProductListView(products: $productList)
//        }
//    }
//}

struct ProductListView: View {
    @Binding var products: [Product]
    let blueColor = Color(uiColor: UIColor.blue);
    let rows = [GridItem(.fixed(20)), GridItem(.fixed(20))]

    var body: some View {
        List {
            ForEach(products.indices, id: \.self) { index in
                let item = products[index]

                NavigationLink {
                    ProductDetailView(product: $products[index])
                } label: {
                    Image("Cube")
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(blueColor, lineWidth: 1))
                        .scaleEffect(CGSize(width: 1.0, height: 1.0))
                        .disabled(true)
                    Spacer(minLength: 12.0)
                    VStack(alignment: .leading){
                        Text("\(item.name)")
                        HStack {
                            ForEach(0..<item.level, id: \.self) { _ in
                                Image(systemName:"star.fill").scaleEffect(CGSizeMake(0.8, 0.8)).foregroundColor(.yellow)
                            }
                        }
                        Text("\(LocalizedStringResource(stringLiteral: "\(item.isTaskComplete ? "Completed" : "ToDo")")) ")
                            .font(.subheadline)
                        +
                        Text(Image(systemName: item.isTaskComplete ? "checkmark.circle.fill" : "checkmark.circle"))
                            .font(.subheadline)
                            .foregroundColor(item.isTaskComplete ? .green : .pink)
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
