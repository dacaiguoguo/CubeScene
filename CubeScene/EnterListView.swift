//
//  EnterListView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI


struct Product: Decodable {
    
    /// 形状名称
    let name:String
    
    /// 形状数据 三位数组
    let matrix:Matrix3D
    
    /// 形状用到哪些块
    let usedBlock: [Int]
    
    /// 形状拼接的顺序，从底层遍历得出，暂时不支持自定义顺序，TO支持自定义顺序
    let orderBlock: [Int]
    
    /// 标记形状是否完成
    var isTaskComplete: Bool
    
    /// 形状难度等级
    let level: Int
    
    init(name: String, matrix: Matrix3D, isTaskComplete: Bool) {
        self.name = name
        self.matrix = matrix
        let temp = Product.orderList(matrix: matrix)
        self.usedBlock = Array(Set(temp.map({ item in
            mapColorIndex(item)
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
                    if value < 0 {
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

extension Product: Identifiable {
    var id: String {
        name
    }
}


/// 解析文件得到要展示的形状数据数组
/// - Parameter resourceName: 数据文件名，在main bundle里
/// - Returns: 形状数组
func produceData(resourceName:String) -> [Product]  {
    let stringContent = try! String(contentsOf: Bundle.main.url(forResource: resourceName, withExtension: "txt")!, encoding: .utf8)
    let ret = produceData2(stringContent: stringContent)
    return ret
}

/// 解析字符串得到要展示的形状数据数组
/// - Parameter stringContent: 要解析的字符串
/// - Returns: 形状数组
/// - Note: 第一行 以/SOMA开头
func produceData2(stringContent:String) -> [Product]  {
    let firstArray = stringContent.components(separatedBy: "/SOMA")
    let trimmingSet:CharacterSet = {
        var triSet = CharacterSet.whitespacesAndNewlines
        triSet.insert("/")
        return triSet
    }()
    let charactersOfV = "VLTZABP"
    
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
                    if charactersOfV.contains(subSubItem) {
                        let character: Character = subSubItem
                        if let asciiValue = character.unicodeScalars.first?.value {
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
            return Product(name: name, matrix: result, isTaskComplete: UserDefaults.standard.bool(forKey: name))
        } else {
            return Product(name: "无名", matrix: result, isTaskComplete: false)
        }
    }
}

let blueColor = Color(uiColor: UIColor(hex: "00bfff"));


struct EnterListView: View {
    @EnvironmentObject var userData: UserData
    @State var productList: [Product]
    var body: some View {
        List {
            ForEach(productList) { product in
                ProductRow(product: product)
                    .listRowBackground(Color.clear)  // 设置行背景为透明
                
            }
            .onAppear {
            }
            .listStyle(PlainListStyle())  // 设置 List 为纯净风格
        }
    }
    
    struct ProductRow: View {
        @EnvironmentObject var userData: UserData
        @State var product: Product  // 假设 Product 是你的数据模型

        var body: some View {
            NavigationLink(destination: SingleContentView(dataModel: $product).environmentObject(userData)) {
                HStack {
                    ProductImage(product: product)
                    ProductDetails(product: product)
                    Spacer()
                }
                .padding()  // 为上下方向添加内边距
                .background(Color.white)  // 设置卡片背景颜色
                .cornerRadius(10)  // 设置圆角
                .shadow(color: .gray, radius: 5, x: 0, y: 2)  // 添加阴影效果
            }
            .buttonStyle(PlainButtonStyle())  // 移除箭头和按钮样式
//            .listRowInsets(EdgeInsets())  // 设置自定义的行内边距，这里使用默认值来最小化内边距
        }
    }

    
    
    // 提取的产品图片视图
    struct ProductImage: View {
        let product: Product
        @EnvironmentObject var userData: UserData
        
        var body: some View {
            if let uiimage = UIImage(named: product.name) {
                Image(uiImage: uiimage)
                    .resizable()
                    .aspectRatio(contentMode: .fill).clipped()
                    .frame(width: 100, height: 100)
                    // .overlay(RoundedRectangle(cornerRadius: 8).stroke(blueColor, lineWidth: 1))
                    .disabled(true)
            } else {
                ScenekitSingleView(dataModel: product, showType: .singleColor, colors: userData.colorSaveList, numberImageList: userData.textImageList)
                    .frame(width: 100, height: 100)
                    // .overlay(RoundedRectangle(cornerRadius: 8).stroke(blueColor, lineWidth: 1))
                    .disabled(true)
            }
        }
    }
    
    // 提取的产品详情视图
    struct ProductDetails: View {
        let product: Product
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(product.name).padding(.bottom, 8)
                StarRating(rating: product.level)
                TaskStatus(isComplete: product.isTaskComplete)
            }
        }
    }
    
    // 提取的星级评价视图
    struct StarRating: View {
        let rating: Int
        
        var body: some View {
            HStack {
                ForEach(0..<rating, id: \.self) { _ in
                    Image(systemName: "star.fill").scaleEffect(0.8).foregroundColor(.yellow)
                }
            }.padding(.bottom, 8)
        }
    }
    
    // 提取的任务状态视图
    struct TaskStatus: View {
        let isComplete: Bool
        
        var body: some View {
            if #available(iOS 16, *) {
                Text(LocalizedStringResource(stringLiteral: isComplete ? "Completed" : "ToDo"))
                    .font(.subheadline)
                +
                Text(Image(systemName: isComplete ? "checkmark.circle.fill" : "checkmark.circle"))
                    .font(.subheadline)
                    .foregroundColor(isComplete ? .green : .pink)
            } else {
                Text(isComplete ? "Completed" : "ToDo")
                    .font(.subheadline)
                +
                Text(Image(systemName: isComplete ? "checkmark.circle.fill" : "checkmark.circle"))
                    .font(.subheadline)
                    .foregroundColor(isComplete ? .green : .pink)
            }
        }
    }
}



struct EnterListView_Previews: PreviewProvider {
    static var previews: some View {
        EnterListView(productList: produceData(resourceName: "SOMA101"))
    }
}
