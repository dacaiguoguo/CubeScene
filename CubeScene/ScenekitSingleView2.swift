//
//  ScenekitSingleView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/17.
//

import SwiftUI
import SceneKit

fileprivate let highlightMaskValue: Int = 2
fileprivate let normalMaskValue: Int = 1

extension SCNNode {
    func setHighlighted( _ highlighted : Bool = true, _ highlightedBitMask : Int = 2 ) {
        if highlighted {
            categoryBitMask = highlightedBitMask
            for child in self.childNodes {
                child.setHighlighted()
            }
        } else {
            categoryBitMask = normalMaskValue
            for child in self.childNodes {
                child.setHighlighted(false)
            }
        }
      
    }
}

// 这些是 SceneKit 中的调试选项，用于在 `SCNView` 中显示不同的调试信息。这些选项可用于开发和调试 3D  场景。以下是每个选项的简要解释：
//
// 1. `.showPhysicsShapes`: 在场景中显示物理形状，以便查看物理引擎中的碰撞体积。
//
// 2. `.showBoundingBoxes`: 显示物体的边界框，以帮助调试和定位对象。
//
// 3. `.showLightInfluences`: 显示光照影响的区域，可用于调试光照效果。
//
// 4. `.showLightExtents`: 显示光源的范围，有助于调试光源的位置和辐射范围。
//
// 5. `.showPhysicsFields`: 显示物理场，用于模拟一些物理效果，如重力场。
//
// 6. `.showWireframe`: 以线框模式显示场景，用于查看场景中对象的几何结构。
//
// 7. `.renderAsWireframe`: 将场景渲染为线框，而不是实体，用于查看对象的轮廓。
//
// 8. `.showSkeletons`: 显示模型的骨骼结构，用于调试动画和骨骼层次结构。
//
// 9. `.showCreases`: 在场景中显示凹槽和棱角，用于调试模型的曲面细分。
//
// 10. `.showConstraints`: 显示应用于对象的约束，帮助调试对象之间的相对关系。
//
// 11. `.showCameras`: 显示场景中相机的位置和方向。
//
// 12. `.showFeaturePoints`: 显示 ARKit 中检测到的特征点，用于调试增强现实场景。
//
// 13. `.showWorldOrigin`: 显示场景的原点，通常是 (0, 0, 0) 点，有助于定位和对齐对象。
//
// 你可以通过在 `SCNView` 中的 `debugOptions` 属性中组合这些选项，以在场景中启用或禁用相应的调试信息。例如：
//
// ```swift
// sceneView.debugOptions = [.showBoundingBoxes, .showWireframe, .showPhysicsShapes]
// ```
//
// 这将在场景中显示边界框、线框和物理形状。

struct ScenekitSingleView2 : UIViewRepresentable {

    let scene: SCNScene = {
        let scene = SCNScene()
        
        let camera = SCNCamera()
        camera.focalLength = 30
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3Make(-10.5, 10.5, 20)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/9, -Float.pi/6, 0)
        
        scene.rootNode.addChildNode(cameraNode)
        
        
        let sky =  MDLSkyCubeTexture(
            name: "sky",
            channelEncoding: .float16,
            textureDimensions: vector_int2(128, 128),
            turbidity: 0.1,
            sunElevation: 1.5,
            upperAtmosphereScattering: 0.5,
            groundAlbedo: 0.5
        )
        sky.groundColor = UIColor.black.cgColor
        sky.update()
        scene.background.contents = sky
        
//        // 创建包含六个面的天空盒贴图数组
//        let skyboxImages = [
//            "wenli5.png",   // 右
//            "wenli5.png",    // 左
//            "wenli5.png",     // 上
//            "bgmuban.png",  // 下（这里应使用棕色填充的图像）
//            "wenli5.png",   // 前
//            "wenli5.png"     // 后
//        ].map{UIImage(named: $0)}
//
//        // 将天空盒贴图设置为场景的背景
//        scene.background.contents = skyboxImages

        
        return scene
    }()

    let sceneView = SCNView()
    
    var nodeList: [SCNNode]
    @Binding var selectedSegment:Int

    func makeUIView(context: Context) -> SCNView {
        // sceneView.debugOptions = [.showCameras, SCNDebugOptions(rawValue: 2048)]
        // scnView.showsStatistics = true
        let parNode2 = SCNNode()

        nodeList.forEach { item in
            parNode2.addChildNode(item)
        }
        scene.rootNode.addChildNode(Origin(length: 10))
        scene.rootNode.addChildNode(parNode2)
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
           sceneView.addGestureRecognizer(tapGesture)
        
        if let path = Bundle.main.path(forResource: "NodeTechnique", ofType: "plist") {
            if let dict = NSDictionary(contentsOfFile: path)  {
                let dict2 = dict as! [String : AnyObject]
                let technique = SCNTechnique(dictionary:dict2)

                // set the glow color to yellow
                let color = SCNVector3(1.0, 1.0, 0.0)
                technique?.setValue(NSValue(scnVector3: color), forKeyPath: "glowColorSymbol")

                self.sceneView.technique = technique
            }
        }
        return sceneView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    
    func updateUIView(_ scnView: SCNView, context: Context) {}
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: ScenekitSingleView2
        
        init(parent: ScenekitSingleView2) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let sceneView = parent.sceneView
            let location = gestureRecognizer.location(in: sceneView)
            let hitTestResults = sceneView.hitTest(location, options: nil)
            
            guard let firstHit = hitTestResults.first else { return }
            let tappedNode = firstHit.node
            // Access the parent and neighboring nodes here
            if let parentNode = tappedNode.parent , let parentNodename = parentNode.name, parentNodename.hasPrefix("块") {
                let numberString = String(parentNodename.filter { "0"..."9" ~= $0 })
                if let number = Int(numberString) {
                    // 这里应该和name匹配 ，而不是index匹配，也就是binding的应该是blockname，而不是selectedSegment
                    self.parent.selectedSegment = number - 1
                } else {
                    print("No number found in the string")
                }
                if let scene = sceneView.scene {
                    scene.rootNode.enumerateHierarchy { (acnnode, _) in
                        acnnode.setHighlighted(false)
                    }
                }
                // Highlight parent node an all child
                parentNode.childNodes.forEach { acnnode in
                    if let name = acnnode.name, name != "yuanNode" {
                        acnnode.setHighlighted(true)
                    }
                }
            }
        }
    }

}

struct ScenekitSingleView2_Previews: PreviewProvider {
    static private var nodeList:[SCNNode] = []

    static var previews: some View {
        NavigationView {
            ScenekitSingleView2(nodeList: nodeList, selectedSegment: .constant(0))
            .navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .previewDevice(PreviewDevice(rawValue: "iPhone SE"))
        .previewDisplayName("iPhone SE")
        
    }
}
