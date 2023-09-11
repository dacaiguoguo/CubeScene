//
//  EnterListView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI


struct EnterItem: Decodable {
    let name:String
    let matrix:Matrix3D
    let usedBlock: [Int]
    let orderBlock: [Int]
    var isTaskComplete: Bool
    let level: Int

    init(name: String, matrix: Matrix3D, isTaskComplete: Bool) {
        self.name = name
        self.matrix = matrix
        let temp = EnterItem.orderList(matrix: matrix)
        self.usedBlock = Array(Set(temp.map({ item in
            switch item {
            case 86:// V
                return 1
            case 76:// L
                return 2;
            case 84:// T
                return 3;
            case 90:// Z
                return 4;
            case 65:// A
                return 5;
            case 66:// B
                return 6;
            case 80:// P
                return 7;
            default:
                return item
            }
        }))).sorted(by: {$0 < $1})

        self.orderBlock = temp
        self.isTaskComplete = isTaskComplete
        switch usedBlock.count {
        case 2:
            self.level = 1
        case 3:
            self.level = 1
        case 4:
            self.level = 2
        case 5:
            self.level = 3
        case 6:
            self.level = 3
        case 7:
            self.level = 4
        default:
            self.level = 4
        }
    }
    /*
     [[[2,4,3], [6,4,1], [6,6,1]],
     [[2,3,3], [6,4,1], [7,4,5]],
     [[2,2,3], [7,5,5], [7,7,5]]]
     */
    static func orderList(matrix:Matrix3D) -> [Int] {
        guard matrix.count > 0 else {
            return []
        }
        let countOfRow = matrix.count
        let countOfLayer = matrix.first?.count ?? -1
        let countOfColum = matrix.first?.first?.count ?? -1
        var ret:[Int] = []
        for y in (0..<countOfLayer).reversed() {
            for x in (0..<countOfColum).reversed() {
                for z in (0..<countOfRow).reversed() {
                    let value = matrix[z][y][x];
                    if value == -1 {
                        continue
                    }
                    if !ret.contains(value) {
                        ret.append(value)
                    }
                }
            }
        }
        return ret
    }
}

extension EnterItem: Identifiable {
    var id: String {
        name
    }
}

func produceData(resourceName:String) -> [EnterItem]  {
    let stringContent = try! String(contentsOf: Bundle.main.url(forResource: resourceName, withExtension: "txt")!, encoding: .utf8)
    return produceData2(stringContent: stringContent)
}

func produceData2(stringContent:String) -> [EnterItem]  {
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

                    if subSubItem == "V" || subSubItem == "L" || subSubItem == "T" || subSubItem == "A" || subSubItem == "B" || subSubItem == "P" || subSubItem == "Z"
                    {
                        let character: Character = subSubItem
                        if let asciiValue = character.unicodeScalars.first?.value {
                            print("\(character)  :ASCII值为: \(asciiValue)")
                            return Int(asciiValue);
                        } else {
                            print("无法获取ASCII值")
                        }
                        return -1
                    }


//                        if subSubItem == "," {
//                            return -1;
//                        }
                    //    if subSubItem == ";" {
                    //        return 0;
                    //    }
                    //    if subSubItem == "@" {
                    //        return 7;
                    //    }
                    //    if subSubItem == "." {
                    //        return 1;
                    //    }
                    //    if subSubItem == "-" {
                    //        return 2;
                    //    }
                    //    if subSubItem == ":" {
                    //        return 3;
                    //    }
                    //    if subSubItem == "+" {
                    //        return 4;
                    //    }
                    //    if subSubItem == "=" {
                    //        return 5;
                    //    }
                    //    if subSubItem == "#" {
                    //        return 3;
                    //    }

                    // .-:+*=
                    let ret = Int(String(subSubItem)) ?? -1
                    return ret
                }
            }
        }

        if let name = firstLine {
            return EnterItem(name: name, matrix: result, isTaskComplete: UserDefaults.standard.bool(forKey: name))
        } else {
            return EnterItem(name: "无名", matrix: result, isTaskComplete: false)
        }
    }
}


struct EnterListView: View {
    @EnvironmentObject var userData: UserData
    @State var productList: [EnterItem]
    let blueColor = Color(uiColor: UIColor(hex: "00bfff"));
    var body: some View {
        List{
            ForEach(productList.indices, id: \.self) { index in
                let item = productList[index]
                NavigationLink(destination: SingleContentView(dataModel: $productList[index]).environmentObject(userData)) {
                    if let uiimage = UIImage(named: item.name) {
                        Image(uiImage: uiimage)
                            .resizable(resizingMode: .stretch)
                            .aspectRatio(contentMode: .fill).clipped()
                            .frame(width: 100.0, height: 100.0, alignment: .center)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(blueColor, lineWidth: 1))
                            .disabled(true)
                    } else {
                        ScenekitSingleView(dataModel:item, showType: .singleColor, colors: userData.colorSaveList, numberImageList: userData.textImageList).frame(width: 100, height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(blueColor, lineWidth: 1))
                            .disabled(true)
                    }
                    Spacer(minLength: 12.0)
                    VStack(alignment: .leading){
                        Text("\(item.name)").padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                        HStack {
                            ForEach(0..<item.level, id: \.self) { _ in
                                Image(systemName:"star.fill").scaleEffect(CGSizeMake(0.8, 0.8)).foregroundColor(.yellow)
                            }
                        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                        if #available(iOS 16, *) {
                            Text("\(LocalizedStringResource(stringLiteral: "\(item.isTaskComplete ? "Completed" : "ToDo")")) ")
                                .font(.subheadline)
                            +
                            Text(Image(systemName: item.isTaskComplete ? "checkmark.circle.fill" : "checkmark.circle"))
                                .font(.subheadline)
                                .foregroundColor(item.isTaskComplete ? .green : .pink)
                        } else {
                            Text("\(item.isTaskComplete ? "Completed" : "ToDo")")
                                .font(.subheadline)
                            +
                            Text(Image(systemName: item.isTaskComplete ? "checkmark.circle.fill" : "checkmark.circle"))
                                .font(.subheadline)
                                .foregroundColor(item.isTaskComplete ? .green : .pink)
                        }

                    }
                }
            }
            // .listRowBackground(Color(uiColor: UIColor(hex: "f8f8f8")))
        }
    }
}



struct EnterListView_Previews: PreviewProvider {
    static var previews: some View {
        EnterListView(productList: produceData(resourceName: "SOMA101"))
    }
}
