//
//  CubeSceneApp.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/6/19.
// 自定义修改颜色，和默认配色
// 1.增加按钮 标记已经玩过。完成
// 国际化 部分完成
// TODO: EnterListView 入口优化为图片
// TODO: 增加240种演示动画
// TODO: 增加难度星级标识和筛选
// TODO: 增加单步骤动画
// TODO: 限制x轴旋转角度 防止翻转 增加恢复位置按钮
// TODO: 分为3个tab，第一个108种，第二个立方体的240种解法，第三个创意玩法，第四个我的（设置，关于入口）


import SwiftUI
import UIKit



// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print(">> your code here !!")
        return true
    }
}

// 生成一次 优化效率
func generateImage(color: UIColor, text: String) -> UIImage {
    let size = CGSize(width: 100, height: 100)
    let renderer = UIGraphicsImageRenderer(size: size)

    let image = renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 46),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]

        let attributedText = NSAttributedString(string: text, attributes: attributes)
        attributedText.draw(at: CGPoint(x: 35, y: 23))
    }

    return image
}

func getTextImageList() -> [UIImage] {
    return Array(0...7).map { index in
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let fileURL = documentsDirectory.appendingPathComponent("blockside\(index).png")
            if let ret = UIImage(contentsOfFile: fileURL.path()) {
                return ret
            } else {
                return UIImage(named: "c1")!;
            }
        } else {
            return UIImage(named: "c1")!;
        }
    }
}

class UserData: ObservableObject {
    @Published var colorSaveList:[UIColor] {
        didSet {
            // 设置后把颜色写入文件，同时更新文字图片
            for (index, item) in colorSaveList.enumerated() {
                UserDefaults.standard.set(item.encode(), forKey: "block\(index)")
                if let imageData = generateImage(color: item, text: "\(index)").pngData(),
                    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsDirectory.appendingPathComponent("blockside\(index).png")
                    do {
                        try imageData.write(to: fileURL)
                        print("Image saved successfully. File path: \(fileURL)")
                    } catch {
                        print("Error saving image: \(error)")
                    }
                }
            }
            // 同步修改文字图片
            self.textImageList = getTextImageList()
        }
    }
    var textImageList:[UIImage]
    
    init() {
        // 默认颜色
        let array = [UIColor(hex: "000000"),
                     UIColor(hex: "FF8800"),
                     UIColor(hex: "0396FF"),
                     UIColor(hex: "EA5455"),
                     UIColor(hex: "7367F0"),
                     UIColor.gray,
                     UIColor(hex: "28C76F"),
                     UIColor.purple];
        // 根据颜色生成带数字的图片，写入ducument
        for (index, item) in array.enumerated() {
            UserDefaults.standard.register(defaults: ["block\(index)" : item.encode()!])
            if let imageData = generateImage(color: item, text: "\(index)").pngData(),
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("blockside\(index).png")
                do {
                    try imageData.write(to: fileURL)
                    print("Image saved successfully. File path: \(fileURL)")
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
        // 赋值
        self.colorSaveList = Array(0...7).map { index in
            if let data = UserDefaults.standard.data(forKey: "block\(index)") {
                return UIColor.decode(data: data) ?? UIColor.purple
            } else {
                return UIColor.orange;
            }
        }
        // 赋值图片
        self.textImageList = getTextImageList()
    }
    

}

@main
struct CubeSceneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) var scenePhase

    let userData = UserData()

    func showButton() -> some View {
        NavigationLink {
            SettingView().environmentObject(userData)
        } label: {
            Image(systemName: "info.circle")
        }
    }
    
    func helpButton() -> some View {
        NavigationLink {
            ConfigView().environmentObject(userData)
        } label: {
            Image(systemName: "gear.circle")
        }
    }

    init() {
        print("init app")
    }
   @State var demo = EnterItem(name: "测试", matrix: [[[2,4,3], [6,4,1], [6,6,1]],
                                                    [[2,3,3], [6,4,1], [7,4,5]],
                                                    [[2,2,3], [7,5,5], [7,7,5]]], usedBlock: [1,2,3,4,5,6,7], isTaskComplete: true)
    var body: some Scene {
        WindowGroup {
            NavigationView {
                SingleContentView(dataModel:$demo)
                .environmentObject(userData)
                .navigationTitle("索玛立方体").navigationBarTitleDisplayMode(.inline)

            }
            .navigationViewStyle(StackNavigationViewStyle())
//            TabView {
//                NavigationView {
//                    EnterListView(productList: produceData(resourceName: "SOMA108")).navigationTitle("TitleName").navigationBarTitleDisplayMode(.inline)
//                        .onAppear {
//                            print("onAppear EnterListView !")
//                        }.environmentObject(userData)
//                }
//                .navigationViewStyle(StackNavigationViewStyle()).tabItem {
//                    Image(systemName: "cube")
//                    Text("TabTitleName")
//                }.tag(0)
//
//                NavigationView {
//                    EnterListView240().environmentObject(userData)
//                        .navigationBarTitleDisplayMode(.inline)
//                        .navigationTitle("TitleName2")
//                }.tabItem {
//                    Image(systemName: "cube.transparent")
//                    Text("TabTitleName2")
//                }.tag(1)
//                NavigationView {
//                    EnterListView(productList: produceData(resourceName: "SOMAT101")).navigationTitle("TitleName3").navigationBarTitleDisplayMode(.inline)
//                        .onAppear {
//                            print("onAppear EnterListView !")
//                        }.environmentObject(userData)
//                }
//                .navigationViewStyle(StackNavigationViewStyle()).tabItem {
//                    Image(systemName: "scribble.variable")
//                    Text("TabTitleName3")
//                }.tag(2)
//                NavigationView {
//                    SettingView().environmentObject(userData)
//                        .navigationBarTitleDisplayMode(.inline)
//                        .navigationTitle("TitleName4")
//                }.tabItem {
//                    Image(systemName: "cube.transparent")
//                    Text("TabTitleName4")
//                }.tag(3)
//            }

        }.onChange(of: scenePhase) { phase in
            if phase == .active {
                // Perform launch tasks
                performLaunchTasks()
            }
        }
    }

    func performLaunchTasks() {
        // 执行应用程序启动时的操作
        print("App performLaunchTasks!")
        // ...
    }
}
