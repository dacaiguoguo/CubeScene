//
//  SettingView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/1.
//

import SwiftUI
import UIKit
import RevenueCat
import RevenueCatUI
import Foundation

extension String {
    /// 返回一个使用本地化字符串初始化的Text视图
    var localizedText: Text {
        Text(LocalizedStringKey(self))
    }
}

// 使用方式
struct ContentView: View {
    var body: some View {
        // 这里的 "hello.world" 将会被查找在本地化文件中对应的值
        "hello.world".localizedText
    }
}


extension String {
    /// 返回本地化后的字符串
    /// - Parameter comment: 用于解释翻译目的和上下文的注释
    /// - Returns: 本地化的字符串
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }
}

// 使用方式
let title = "hello.world".localized(comment: "A greeting to the world")


//在SwiftUI中，展示loading指示器和toast提示信息通常需要使用一些自定义视图和状态管理。下面是如何实现这两种功能的示例：
//
//### Loading 指示器
//
//SwiftUI原生提供了`ProgressView`，可以用作loading指示器。以下是一个简单的例子，展示了如何在数据加载时显示一个loading指示器：
//
//```swift
import SwiftUI

struct LoadingView: View {
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            Button("Load Data") {
                isLoading = true
                // 模拟数据加载过程
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false
                }
            }
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
//```
//
//### Toast 提示
//
//SwiftUI没有内置的toast组件，但你可以很容易地自定义一个。以下是一个简单的toast视图实现，当触发一个动作时显示，并在几秒钟后自动消失：
//
//```swift

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let text: Text
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                VStack(alignment: .center) {
                    // Spacer()
                    text
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(Color.white)
                        .cornerRadius(8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    isShowing = false
                                }
                            }
                        }
                }
                .padding()
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, text: Text) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, text: text))
    }
}


//```
//
//在这个toast实现中，我们创建了一个`ToastModifier`视图修饰符，它使用`isShowing`状态来控制toast是否可见，并使用`Text`显示消息。`toast`扩展方法可以轻松地应用到任何`View`上，以添加toast功能。Toast通过改变透明度和位置来实现淡入淡出的动画效果。
//
//请注意，这些示例可以根据你的具体需求进行调整和扩展。

// UIColor 扩展，用于实现归档和解档操作
extension UIColor {
    func encode() -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    static func decode(data: Data) -> UIColor? {
        do {
            let unarchivedObject = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
            return unarchivedObject
            // Use the unarchived object
        } catch {
            print("Error unarchiving data: \(error)")
        }
        
        return nil
    }
}

extension UIColor {
    public convenience init(hex: String) {
        let r, g, b, a: CGFloat
        let hex2 = "#\(hex)ff"
        let start = hex2.index(hex2.startIndex, offsetBy: 1)
        let hexColor = String(hex2[start...])
        
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
                
                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }
        
        self.init(red: 0, green: 0, blue: 0, alpha: 1)
        return
    }
}


struct Channel: Decodable {
    var channelID:String = ""
    var name:String = ""
    var link:String = ""
}

extension Channel: Identifiable {
    var id: String {
        channelID
    }
}


public struct SettingView: View {
    @State private var showToast = false
    @State private var showingPaywall = false
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userData: UserData
    let persistenceController = PersistenceController.shared
    @State var showText = "success"
    @State var showPurchase = false
    
    public init(){}
    
    let channelLocalDataList:[Channel] = [Channel(channelID: "1", name: "ContentSoma", link: "https://dacaiguoguo.github.io/PrivacyPolicy.html"),
                                          Channel(channelID: "2", name: "ContentAuthor", link: "mailto:dacaiguoguo@163.com"),
                                          Channel(channelID: "3", name: "Privacy Policy", link: "https://dacaiguoguo.github.io/PrivacyPolicy.html"),
                                          Channel(channelID: "4", name: "Terms Of Use", link: "https://dacaiguoguo.github.io/teamuse/termsofuse.html")]
    @State private var showingSheet = false
    @State private var currentIcon:String = cicon()

    public var body: some View {
        
        List {
            Section(content: {
                ForEach(channelLocalDataList) { channel in
                    Link(LocalizedStringKey(channel.name), destination: URL(string: channel.link)!)
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            })
            Section(content: {
                Button {
                    self.showingSheet = true

                } label: {
                    Text("Choose Icon").font(.headline) + Text("     Current:\(currentIcon)")
                }
                .actionSheet(isPresented: $showingSheet) {
                    ActionSheet(
                        title: Text("Choose Icon") + Text("Current:\(currentIcon)"),
                        message: Text("Choose new Icon"),//请选择一个新的 App 图标
                        buttons: [
                            .default(Text("Default")) { self.changeIcon(to: nil) },
                            .default(Text("AppIcon1")) { self.changeIcon(to: "AppIcon1") },
                            .default(Text("AppIcon2")) { self.changeIcon(to: "AppIcon2") },
                            .cancel()
                        ]
                    )
                }
            })
            
            Section(content: {
                Text("Purchases")
            }) .paywallFooter()
            
            Section(content: {
                NavigationLink {
                    ConfigView().environmentObject(userData)
                } label: {
                    HStack{
                        Text("TitleSetting")
                        Spacer()
                        Image(systemName: "gear.circle")
                    }
                }
                
                NavigationLink {
                    EnterListView(productList: produceData(resourceName: "SOMAX101")).navigationTitle("TabTitleNameX").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
                        }.environmentObject(userData)
                } label: {
                    HStack{
                        Text("TabTitleNameX")
                        Spacer()
                        Image(systemName: "highlighter")
                    }
                }
                NavigationLink {
                    EnterListView(productList: produceData(resourceName: "SOMAY101")).navigationTitle("TabTitleNameY").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
                        }.environmentObject(userData)
                } label: {
                    HStack{
                        Text("TabTitleNameY")
                        Spacer()
                        Image(systemName: "highlighter")
                    }
                }
                
                NavigationLink {
                    EnterListView(productList: produceData(resourceName: "SOMAW101")).navigationTitle("TabTitleNameW").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
                        }.environmentObject(userData)
                } label: {
                    HStack{
                        Text("TabTitleNameW")
                        Spacer()
                        Image(systemName: "highlighter")
                    }
                }
                NavigationLink {
                    EnterListView(productList: produceData(resourceName: "SOMAC3A101")).navigationTitle("SOMA C3A").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
                        }.environmentObject(userData)
                } label: {
                    HStack{
                        Text("SOMA C3A")
                        Spacer()
                        Image(systemName: "highlighter")
                    }
                }
                
                NavigationLink {
                    EnterListView(productList: produceData(resourceName: "SOMAC3B101")).navigationTitle("SOMA C3B").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
                        }.environmentObject(userData)
                } label: {
                    HStack{
                        Text("SOMA C3B")
                        Spacer()
                        Image(systemName: "highlighter")
                    }
                }
                NavigationLink {
                    EnterListView(productList: produceData(resourceName: "SOMAC3C101")).navigationTitle("SOMA C3C").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
                        }.environmentObject(userData)
                } label: {
                    HStack{
                        Text("SOMA C3C")
                        Spacer()
                        Image(systemName: "highlighter")
                    }
                }
                NavigationLink {
                    EnterListView(productList: produceData(resourceName: "SOMAC3D101")).navigationTitle("SOMA C3D").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
                        }.environmentObject(userData)
                } label: {
                    HStack{
                        Text("SOMA C3D")
                        Spacer()
                        Image(systemName: "highlighter")
                    }
                }
                NavigationLink {
                    EnterListView(productList: produceData(resourceName: "SOMAC4A101")).navigationTitle("SOMA C4A").navigationBarTitleDisplayMode(.inline)
                        .onAppear {
                            
                        }.environmentObject(userData)
                } label: {
                    HStack{
                        Text("SOMA C4A")
                        Spacer()
                        Image(systemName: "highlighter")
                    }
                }
                
            })
            Section(content: {
                
                NavigationLink {
                    ChaiZiView<JtItem>(filename: "chaizi-jt", titleStr: "简体拆字字典")
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } label: {
                    HStack{
                        Text("简体拆字")
                        Spacer()
                        Image(systemName: "lasso")
                    }
                }
                
                NavigationLink {
                    ChaiZiView<FtItem>(filename: "chaizi-ft", titleStr: "繁体拆字字典")
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                } label: {
                    HStack{
                        Text("繁体拆字")
                        Spacer()
                        Image(systemName: "lasso.and.sparkles")
                    }
                }
            })
            
            
        }.onAppear(perform: {
            Purchases.shared.getCustomerInfo { (customerInfo, error) in
                if let error = error {
                    print("Failed to retrieve customer info: \(error.localizedDescription)")
                    return
                }
                
                if customerInfo?.entitlements.all["soma_t"]?.isActive == true {
                    // 用户是"premium"用户
                    self.showPurchase = false
                    SubscriptionManager.shared.isPremiumUser = true;
                    print("User is premium")
                } else {
                    // 用户不是"premium"用户
                    self.showPurchase = true
                    print("User is not premium")
                }
            }
        })
        .toast(isShowing: $showToast, text: showText.localizedText)
        .navigationTitle("TitleHelp")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    static func cicon() -> String {
        if let currentIcon = UIApplication.shared.alternateIconName {
            print("当前的 App 图标是: \(currentIcon)")
            return currentIcon
        } else {
            print("当前使用的是默认 App 图标")
            return "Default"
        }
    }
    
    func changeIcon(to iconName: String?) {
        UIApplication.shared.setAlternateIconName(iconName) { error in
            currentIcon = SettingView.cicon()
            if let error = error {
                print("图标切换失败: \(error.localizedDescription)")
            } else {
                print("图标已更改。")
            }
        }
    }
}



struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingView()
        }
    }
}
