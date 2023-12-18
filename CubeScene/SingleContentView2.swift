//
//  SingleContentView2.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import SceneKit

public struct SingleContentView2: View {
    
    let segments = {[1,2,3,4,5,6,7].map { index in
        return "块 \(index)"
    }}()
    
    @State private var counter:Double = 0
    @State private var selectedSegment = 0
    @State var nodeList:[SCNNode]
    //    { makeNode(with result: result)}()
    
    @State private var stepcount = 0 {
        didSet {
            triggerHapticFeedback()
        }
    }
    
    public var body: some View {
        VStack {
            ZStack(alignment: .bottomTrailing) {
                ScenekitSingleView2(nodeList: nodeList, selectedSegment: $selectedSegment)
                HStack{
                    Spacer()
                    rotationView()
                    stepperView()
                }.frame(height: 150).padding()
                
            }
            pickerView()
            
        }.navigationBarItems(trailing:completeStatus()).navigationTitle(Text("步数:\(stepcount)"))
    }
    func completeStatus() -> some View {
        Group {
            HStack {
                Button(action: {
                    reset()
                }, label: {
                    Text("重置\(Int(floor(counter)))")
                })
                Button(action: {
                    reset()
                    counter += 0.001;
                    actionRunAt(index: 0)
                }, label: {
                    Text("演示")
                })
            }
        }
    }
    
    func reset() {
        counter = floor(counter) + 1;
        nodeList.forEach { node2 in
            node2.position = node2.orgPosition ?? node2.position
            node2.rotation = node2.rotationTo ?? node2.rotation
            node2.transform = node2.transformTo ?? node2.transform;
        }
    }
    
    func actionRunAt(index: Int) -> Void {
        // 判断是否存在小数
        guard counter.truncatingRemainder(dividingBy: 1) != 0 else {
            return
        }
        guard index < nodeList.count else {
            return
        }
        var actionList:[SCNAction] = []
        var topPosition = nodeList[index].positionTo!;
        topPosition.y += 5;
        actionList.append(SCNAction.move(to: topPosition, duration: 0.2));
        let destPosition = nodeList[index].positionTo!;
        actionList.append(SCNAction.rotate(toAxisAngle: SCNVector4Zero, duration: 0.2));
        actionList.append(SCNAction.move(to: destPosition, duration: 0.2));
        nodeList[index].runAction(SCNAction.sequence(actionList), completionHandler: {
            // 判断是否存在小数
            if counter.truncatingRemainder(dividingBy: 1) != 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    actionRunAt(index: index + 1);
                }
            } else {
                print("没有小数")
            }
      
        })
    }
    
    var blockName:String {
        segments[selectedSegment]
    }
    
    func pickerView() -> some View {
        Picker("", selection: Binding(get: {selectedSegment}, set: { newValue in triggerHapticFeedback(); selectedSegment = newValue})) {
            ForEach(0 ..< segments.count, id: \.self) {
                Text(segments[$0])
            }
        }.pickerStyle(.segmented).padding()
    }
    
    func rotationMethod(_ axis: LVAxis) {
        if let cnode = nodeList.filter({ node in
            node.name == blockName
        }).first {
            switch axis {
            case .x:
                cnode.runAction(SCNAction.routeXPI_2(duration: 0.1))
            case .y:
                cnode.runAction(SCNAction.routeYPI_2(duration: 0.1))
            case .z:
                cnode.runAction(SCNAction.routeZPI_2(duration: 0.1))
            }
        }
        stepcount += 1;
    }
    
    func rotationView() -> some View {
        VStack {
            CustomButton(title: "旋转X", titleColor:.blue) {rotationMethod(.x)}
            CustomButton(title: "旋转Y", titleColor:.green) {rotationMethod(.y)}
            CustomButton(title: "旋转Z", titleColor:.red)  {rotationMethod(.z)}
        }.padding()
    }
    
    func stepperView() -> some View {
        VStack(alignment: .trailing) {
            Stepper {
                Text("X")
            } onIncrement :{
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(1.0, 0, 0), duration: 0.1))
                stepcount += 1;
            } onDecrement: {
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(-1.0, 0, 0), duration: 0.1))
                stepcount += 1;
            }
            
            Stepper {
                Text("Y")
            } onIncrement :{
                stepcount += 1;
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, 1.0, 0), duration: 0.1))
            } onDecrement: {
                stepcount += 1;
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, -1.0, 0), duration: 0.1))
            }
            
            Stepper {
                Text("Z")
            } onIncrement :{
                stepcount += 1;
                
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, 0, 1.0), duration: 0.1))
            } onDecrement: {
                stepcount += 1;
                
                nodeList.filter({ node in
                    node.name == blockName
                }).first?.runAction(SCNAction.move(by: SCNVector3Make(0, 0, -1.0), duration: 0.1))
            }
        }.frame(width: 120)
    }
    
    func lognodeInfo() -> Void {
        nodeList.forEach { node in
            print("node:\(node.name ?? ""),rotation:\(node.rotation), position:\(node.position)")
        }
    }
    
    func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
        // lognodeInfo()
    }
}


struct CustomButton: View {
    let title: String
    let titleColor: Color//  = .white
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(6)
                .background(Color.white)
                .foregroundColor(titleColor)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(titleColor, lineWidth: 2)
                )
        } .background(Color.yellow)
            .cornerRadius(8)
    }
}

