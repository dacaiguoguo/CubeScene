//
//  EnterListView240.swift
//  CubeScene
//
//  Created by yanguo sun on 2023/7/14.
//

import SwiftUI
import Mixpanel

let resourceName = "solutionsMaped"

struct EnterListView240: View {
    

    @EnvironmentObject var userData: UserData
    @State var productList: [Product] = produceData240(resourceName: resourceName)
    var body: some View {
        ScrollView {
            LazyVGrid(columns: gridLayout, spacing: 20) {
                ForEach(productList) { product in
                    ProductRow(product: product)
                        .listRowBackground(Color.clear)  // 设置行背景为透明
                }
            }
            .padding() // 添加一些内边距
        }
    }
    
    
    // 根据设备类型确定列的数量

    private var gridLayout: [GridItem] {

        // iPad上一行显示3个项目

        let ipadColumns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

        // iPhone上一行显示一个项目

        let iphoneColumn = [GridItem(.flexible()), GridItem(.flexible())]



        return UIDevice.current.userInterfaceIdiom == .pad ? ipadColumns : iphoneColumn

    }
    struct ProductRow: View {
        @EnvironmentObject var userData: UserData
        @State var product: Product  // 假设 Product 是你的数据模型
        @State private var isActive: Bool = false

        var body: some View {
            // 使用按钮来代替 NavigationLink，这样就不会显示箭头
            Button(action: {
                Mixpanel.mainInstance().track(event: "ProductRowisFree", properties: ["Signup": product.name])
                isActive = true
            }) {
                VStack(alignment: .center){
                    ProductImage(product: product)
                    indeText(product)
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
                .hidden()  // 隐藏 NavigationLink，不显示箭头
            )
            .buttonStyle(PlainButtonStyle())  // 移除按钮样式
            // .padding(.horizontal)  // 设置水平边距
            .padding(.vertical, 8)  // 设置垂直边距
        }
        
        func indeText(_ item:Product) -> some View {
            return HStack{
                Text("Kind").foregroundColor(.primary).font(.title2)
                Text("\(item.name)").foregroundColor(.primary).font(.title2)
            }.padding(EdgeInsets(top: 10.0, leading: 10.0, bottom: 0.0, trailing: 0.0))
        }
    }


    
    
    // 提取的产品图片视图
    struct ProductImage: View {
        let product: Product
        @EnvironmentObject var userData: UserData
        
        var body: some View {
            ScenekitSingleView(dataModel:product, showType: .colorFul, colors: userData.colorSaveList, numberImageList: userData.textImageList, showColor: [1, 2, 3, 4, 5, 6, 7])                .frame(maxWidth: .infinity, minHeight: 150)
                // .overlay(RoundedRectangle(cornerRadius: 8).stroke(blueColor, lineWidth: 1))
                .disabled(true)
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
                    .foregroundColor(isComplete ? .green : .black)
            } else {
                Text(isComplete ? "Completed" : "ToDo")
                    .font(.subheadline)
                +
                Text(Image(systemName: isComplete ? "checkmark.circle.fill" : "checkmark.circle"))
                    .font(.subheadline)
                    .foregroundColor(isComplete ? .green : .black)
            }
        }
    }
}



struct EnterListView240_Previews: PreviewProvider {
    static var previews: some View {
        EnterListView240()
    }
}

func produceData240(resourceName:String) -> [Product]  {
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
        
        return Product(name: "\(index + 1)", matrix: item,isTaskComplete: false)
    }
}
