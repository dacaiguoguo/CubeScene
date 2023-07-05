//
//  SettingView.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/1.
//

import SwiftUI


var colorsDefault:[UIColor] = [
    // UIColor.black,
    // UIColor.systemCyan, // front
    // UIColor.green, // right
    // UIColor.red, // back
    // UIColor.systemIndigo, // left
    // UIColor.blue, // top
    // UIColor.purple,
    // UIColor.yellow,
    UIColor(hex: "000000"),
    UIColor(hex: "FF8800"),
    UIColor(hex: "0396FF"),
    UIColor(hex: "EA5455"),
    UIColor(hex: "7367F0"),
    UIColor.gray,
    UIColor(hex: "28C76F"),
    UIColor.purple
]

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
    public init(){}

    //    let channelLocalDataList:[Channel] = [Channel(channelID: "1", name: "色彩"), Channel(channelID: "2", name: "难度"),  Channel(channelID: "3", name: "帮助")]
    let channelLocalDataList:[Channel] = [Channel(channelID: "1", name: "关于索玛立方体", link: "https://dacaiguoguo.github.io/PrivacyPolicy.html"),
                                          Channel(channelID: "2", name: "联系：dacaiguoguo@163.com", link: "mailto:dacaiguoguo@163.com")]

    public var body: some View {
        List {
            Section(content: {
                ForEach(channelLocalDataList) { channel in
                    Link(channel.name, destination: URL(string: channel.link)!)
                        .foregroundColor(.blue)
                        .font(.headline)
                }
            }, header: {
                Text("Hello")
            }, footer: {
//                Text("双指滑动来平移").font(.title).foregroundColor(.black)
//                Text("双指捏合或张开来放大缩小").font(.title).foregroundColor(.black)
            })
        }
    }
}



struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
