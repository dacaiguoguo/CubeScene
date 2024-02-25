//
//  EnterListView.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/2.
//

import SwiftUI
import CoreData
import Mixpanel

typealias Matrix3D = [[[Int]]]
typealias BlockList = [Int]

struct Product: Decodable, Identifiable {
    let name: String
    let matrix: Matrix3D
    let usedBlock: BlockList
    let orderBlock: BlockList
    var isTaskComplete: Bool
    let level: Int
    
    var id: String { name }
    
    init(name: String, matrix: Matrix3D, isTaskComplete: Bool) {
        self.name = name
        self.matrix = matrix
        self.orderBlock = Product.orderList(from: matrix)
        self.usedBlock = Array(Set(orderBlock.filter { $0 >= 0 })).sorted()
        self.isTaskComplete = isTaskComplete
        self.level = Product.determineLevel(from: usedBlock)
    }
    
    private static func orderList(from matrix: Matrix3D) -> BlockList {
        guard !matrix.isEmpty else { return [] }
        return matrix.lazy.reversed().flatMap { layer in
            layer.lazy.reversed().flatMap { row in
                row.reversed()
            }
        }.filter { $0 >= 0 }.removingDuplicates()
    }
    
    private static func determineLevel(from usedBlocks: BlockList) -> Int {
        switch usedBlocks.count {
        case 2...3: return 1
        case 4...5: return 2
        case 6...7: return 3
        default: return 4
        }
    }
}

extension Array where Element: Equatable {
    func removingDuplicates() -> [Element] {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        return result
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

extension Product {
    func toManagedObject(in context: NSManagedObjectContext) -> ProductEntity {
        let productEntity = ProductEntity(context: context)
        productEntity.name = name
        productEntity.isTaskComplete = isTaskComplete
        productEntity.level = Int16(level) // 根据你的模型属性类型调整
        
        // 对于数组和矩阵，你需要将它们转换为合适的格式
        // 例如，将 matrix 转换为 Data
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: self.matrix, requiringSecureCoding: false) {
            productEntity.arrayData = data
        }
        
        
        // 同样，对于 usedBlock 和 orderBlock
        productEntity.usedBlock = self.usedBlock as NSArray
        
        productEntity.orderBlock = self.orderBlock as NSArray
        
        return productEntity
    }
}

import RevenueCatUI

struct EnterListView: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.managedObjectContext) private var viewContext
    @State var displayPaywall = false
    @State var productList: [Product]

    // 根据设备类型确定列的数量
    private var gridLayout: [GridItem] {
        // iPad上一行显示3个项目
        let ipadColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
        // iPhone上一行显示一个项目
        let iphoneColumn = [GridItem(.flexible()), GridItem(.flexible())]

        return UIDevice.current.userInterfaceIdiom == .pad ? ipadColumns : iphoneColumn
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, spacing: 20) {
                ForEach(productList) { product in
                    ProductRow(product: product, displayPaywall: $displayPaywall)
                        .background(Color.clear) // 设置背景为透明
                }
            }
            .padding() // 添加一些内边距
        }
        .sheet(isPresented: $displayPaywall) {
            PaywallView()
                .onPurchaseCompleted { customerInfo in
                    print("Purchase completed: \(customerInfo.entitlements)")
                    self.displayPaywall = false
                    SubscriptionManager.shared.isPremiumUser = true
                }
        }
    }
    
    
    struct ProductRow: View {
        @EnvironmentObject var userData: UserData
        @State var product: Product  // 假设 Product 是你的数据模型
        @State private var isActive: Bool = false
        @Binding var displayPaywall:Bool
        
        var body: some View {
            // 使用按钮来代替 NavigationLink，这样就不会显示箭头
            Button(action: {
                if product.name.hasPrefix("T") || product.name.hasPrefix("C") {
                    if SubscriptionManager.shared.isPremiumUser {
                        isActive = true
                        Mixpanel.mainInstance().track(event: "ProductRowisActive", properties: ["Signup": product.name])
                    } else {
                        Mixpanel.mainInstance().track(event: "displayPaywall", properties: ["Signup": product.name])
                        displayPaywall = true
                    }
                } else {
                    Mixpanel.mainInstance().track(event: "ProductRowisFree", properties: ["Signup": product.name])
                    isActive = true
                }
            }) {
                VStack {
                    Text(product.name).font(.title).foregroundColor(.white).padding(.bottom, 8)
                    StarRating(rating: product.level)
                    ProductImage(product: product)
                    TaskStatus(isComplete: product.isTaskComplete)
                }
                .padding()  // 卡片内边距
                .background(blueColor)  // 卡片背景色
                .cornerRadius(10)  // 卡片圆角
                .shadow(color: .gray, radius: 5, x: 0, y: 2)  // 卡片阴影
            }
            .background(
                NavigationLink(
                    destination: SingleContentView(dataModel: $product).environmentObject(userData),
                    isActive: $isActive
                ) {
                    EmptyView()
                }
            )
            .buttonStyle(PlainButtonStyle())  // 移除按钮样式
            .padding(.vertical, 8)  // 设置垂直边距
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
                    .aspectRatio(contentMode: .fit).clipped()
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .disabled(true)
            } else if let uiimage = UIImage(named: "SOMA-\(product.name)") {
                Image(uiImage: uiimage)
                    .resizable()
                    .aspectRatio(contentMode: .fit).clipped()
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .disabled(true)
            } else {
                ScenekitSingleView(dataModel: product, showType: .singleColor, colors: userData.colorSaveList, numberImageList: userData.textImageList)
                    .frame(maxWidth: .infinity, minHeight: 180)
                    .disabled(true)
            }
        }
    }
    
    // 提取的星级评价视图
    struct StarRating: View {
        let rating: Int
        
        var body: some View {
            HStack(alignment: .center) {
                ForEach(0..<rating, id: \.self) { _ in
                    Image(systemName: "star.fill").scaleEffect(1).foregroundColor(.yellow)
                }
            }.padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
    }
    
    // 提取的任务状态视图
    struct TaskStatus: View {
        let isComplete: Bool
        
        var body: some View {
            HStack(alignment: .center) {
                Text(isComplete ? "Completed" : "ToDo")
                    .foregroundColor(isComplete ? .green : .black)
                    .font(.title2)
                Image(systemName: isComplete ? "checkmark.circle.fill" : "checkmark.circle")
                    .font(.title2)
                    .foregroundColor(isComplete ? .green : .black)
            }
            .padding(.horizontal) // 为文本和图标添加一些内边距
            .background(Color.white) // 设置视图的背景颜色为白色
            .cornerRadius(4) // 设置视图的圆角半径为4
        }
    }

}

struct EnterListView_Previews: PreviewProvider {
    static var previews: some View {
        EnterListView(productList: produceData(resourceName: "SOMA101"))
    }
}
