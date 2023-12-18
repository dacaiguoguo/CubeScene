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
        
        scene.background.contents = MDLSkyCubeTexture(
            name: "sky",
            channelEncoding: .float16,
            textureDimensions: vector_int2(128, 128),
            turbidity: 0.2,
            sunElevation: 1.5,
            upperAtmosphereScattering: 0.5,
            groundAlbedo: 0.5
        )
        
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
        
        // Here we load the technique we'll use to achieve a highlight effect around
        // selected nodes
        if let fileUrl = Bundle.main.url(forResource: "RenderOutlineTechnique", withExtension: "plist"), let data = try? Data(contentsOf: fileUrl) {
          if var result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] { // [String: Any] which ever it is
            
            // Here we update the size and scale factor in the original technique file
            // to whichever size and scale factor the current device is so that
            // we avoid crazy aliasing
            let nativePoints = UIScreen.main.bounds
            let nativeScale = UIScreen.main.nativeScale
            result[keyPath: "targets.MASK.size"] = "\(nativePoints.width)x\(nativePoints.height)"
            result[keyPath: "targets.MASK.scaleFactor"] = nativeScale
            
            guard let technique = SCNTechnique(dictionary: result) else {
              fatalError("This shouldn't be happening! 🤔")
            }

              sceneView.technique = technique
          }
        }
        else {
          fatalError("This shouldn't be happening! Has someone been naughty and deleted the file? 🤔")
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
                        acnnode.setCategoryBitMaskForAllHierarchy(normalMaskValue)
                    }
                }
                // Highlight parent node an all child
                parentNode.childNodes.forEach { acnnode in
                    acnnode.setCategoryBitMaskForAllHierarchy(highlightMaskValue)
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
