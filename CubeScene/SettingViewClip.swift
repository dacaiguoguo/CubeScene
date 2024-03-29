//
//  SettingView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/1.
//

import SwiftUI
import UIKit

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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userData: UserData
    let persistenceController = PersistenceController.shared

    public init(){}

    let channelLocalDataList:[Channel] = [Channel(channelID: "1", name: "ContentSoma", link: "https://dacaiguoguo.github.io/PrivacyPolicy.html"),
                                          Channel(channelID: "2", name: "ContentAuthor", link: "mailto:dacaiguoguo@163.com"),
                                          Channel(channelID: "3", name: "Privacy Policy", link: "https://dacaiguoguo.github.io/PrivacyPolicy.html"),
                                          Channel(channelID: "4", name: "Terms Of Use", link: "https://dacaiguoguo.github.io/teamuse/termsofuse.html")]

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

            
        }.navigationTitle("TitleHelp")
            .navigationBarTitleDisplayMode(.inline)
    }
}



struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingView()
        }
    }
}
