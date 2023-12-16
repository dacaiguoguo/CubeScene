//
//  EnterListView240.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/14.
//

import SwiftUI

struct EnterListView240: View {
    @EnvironmentObject var userData: UserData
//    static private var resourceName = "solutions"
    static private let resourceName = "solutionsMaped"


    @State var productList: [EnterItem] = produceData()
    let blueColor = Color(uiColor: UIColor(hex: "00bfff"));

    var body: some View {
        List{
            ForEach(productList.indices, id: \.self) { index in
                let item = productList[index]
                NavigationLink(destination: SingleContentView2(nodeList: makeNode(with: item.matrix)).environmentObject(userData)) {
                    HStack{
//                        Image("Cube").frame(width: 80, height: 80)
//                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(uiColor: UIColor(hex: "00bfff")), lineWidth: 1))
//                            .disabled(true)
                        ScenekitSingleView(dataModel:item, showType: .colorFul, colors: userData.colorSaveList, numberImageList: userData.textImageList, showColor: [1, 2, 3, 4, 5, 6, 7]).frame(width: 100, height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(blueColor, lineWidth: 1))
                            .disabled(true)
                        VStack(alignment: .leading){
                            Text(item.name).foregroundColor(.primary).font(.title2)
                                .padding(EdgeInsets(top: 10.0, leading: 10.0, bottom: 0.0, trailing: 0.0))
                        }
                    }
                }
            }
        }
    }

    static func produceData() -> [EnterItem]  {
        let jsonContentData = try! JSONSerialization.jsonObject(with: Data(contentsOf: Bundle.main.url(forResource: resourceName, withExtension: "json")!))
//        let jsonObject = (jsonContentData as! [[[[Int]]]]).map { item0 in
//            item0.map { item in
//                item.map { item2 in
//                    item2.map { item3 in
//                        if item3 == 0 {return 2}
//                        if item3 == 1 {return 3}
//                        if item3 == 2 {return 4}
//                        if item3 == 3 {return 1}
//                        if item3 == 4 {return 5}
//                        if item3 == 5 {return 6}
//                        if item3 == 6 {return 7}
//                        return item3
//                    }
//                }
//            }
//        }
//
//        // Convert the JSONObject to Data
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
//            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
//            // Define the file URL where you want to save the JSON data
//            let fileURL = documentsDirectory!.appendingPathComponent("solutionsMaped.json")
//
//            // Write the JSON data to the file
//            try jsonData.write(to: fileURL)
//
//        } catch {
//        }



        return (jsonContentData as! [[[[Int]]]]).enumerated().map { index, item in
            
            return EnterItem(name: "第\(index+1)种", matrix: item,isTaskComplete: false)
        }
    }
}

struct EnterListView240_Previews: PreviewProvider {
    static var previews: some View {
        EnterListView240()
    }
}
