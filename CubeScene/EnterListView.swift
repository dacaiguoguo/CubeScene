//
//  EnterListView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI


struct EnterItem: Decodable {
    let name:String
    var matrix:Matrix3D
}

extension EnterItem: Identifiable {
    var id: String {
        name
    }
}

struct EnterListView: View {

    let firstArray: [EnterItem] = {
        let stringContent = try! String(contentsOf: Bundle.main.url(forResource: "SOMA101", withExtension: "txt")!, encoding: .utf8)
        let firstArray = stringContent.components(separatedBy: "/SOMA")
        let trimmingSet:CharacterSet = {
            var triSet = CharacterSet.whitespacesAndNewlines
            triSet.insert("/")
            return triSet
        }()
        return firstArray.filter { item in
            item.lengthOfBytes(using: .utf8) > 1
        }.map { currentData in
            let splitArray = currentData.trimmingCharacters(in: trimmingSet).split(separator: "\n")
            let firstLine = splitArray.first?.trimmingCharacters(in: trimmingSet).trimmingCharacters(in: CharacterSet(charactersIn: "-"))
            let parsedData = splitArray.dropFirst().filter { item in
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
            if let name = firstLine {
                return EnterItem(name: name, matrix: result)
            } else {
                return EnterItem(name: "无名", matrix: result)
            }
        }
    }()

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                ForEach(Array(firstArray.enumerated()), id: \.0) { index, item in
                    NavigationLink(destination: SingleContentView(dataModel: item)) {
                        ZStack(alignment: .topLeading){
                            Text("\(index)")
                            ScenekitSingleView(dataItem: item.matrix, imageName: item.name).frame(width: 100, height: 100).disabled(true)
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
//        ZStack(alignment: .topLeading){
//            // todo 显示当前image
//            // Image(uiImage: UIImage(named: "c\(index)")!).resizable()
//            Text("001")
//            //                                .foregroundColor(Color.primary)
//            //                                .frame(width: 100, height: 100)
//            //                                .background(Color(uiColor: UIColor.lightGray))
//            ScenekitSingleView(result: [[[2,4,3], [6,4,1], [6,6,1]],
//                                        [[2,3,3], [6,4,1], [7,4,5]],
//                                        [[2,2,3], [7,5,5], [7,7,5]]]).frame(width: 100, height: 100)
//        }
    }
}
