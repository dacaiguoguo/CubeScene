//
//  EnterListView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI

struct EnterListView: View {

    let firstArray: [Matrix3D] = {
        let stringContent = try! String(contentsOf: Bundle.main.url(forResource: "SOMA101", withExtension: "txt")!, encoding: .utf8)
        let firstArray = stringContent.components(separatedBy: "/SOMA")
        return firstArray.filter { item in
            item.lengthOfBytes(using: .utf8) > 5
        }.map { currentData in
            let trimmingSet:CharacterSet = {
                var triSet = CharacterSet.whitespacesAndNewlines
                triSet.insert("/")
                return triSet
            }()
            let parsedData = currentData.trimmingCharacters(in: trimmingSet).split(separator: "\n").dropFirst().filter { item in
                item.hasPrefix("/")
            }.map({ item in
                item.trimmingCharacters(in: trimmingSet)
            })

            let separatorItem = Character("/")
            // 非数字都解析成-1
            let result = parsedData.map { item in
                item.split(separator: separatorItem).map { subItem in
                    subItem.map { subSubItem in
                        Int(String(subSubItem)) ?? -1
                    }
                }
            }
            // print(result)
            return result
        }
    }()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(Array(firstArray.enumerated()), id: \.1) { index, fruit in
                    NavigationLink(destination: SingleContentView(result: fruit)) {
                        ZStack{
                            // todo 显示当前image
                            // Image(uiImage: UIImage(named: "c\(index)")!).resizable()
                            Text("\(index)")
                                .foregroundColor(Color.primary)
                                .frame(width: 100, height: 100)
                                .background(Color(uiColor: UIColor.lightGray))
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct EnterListView_Previews: PreviewProvider {
    static var previews: some View {
        EnterListView()
    }
}
