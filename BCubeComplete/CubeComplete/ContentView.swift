//
//  ContentView.swift
//  CubeComplete
//
//  Created by yanguo sun on 2023/7/12.
//

import SwiftUI

import Foundation


struct RItem: Hashable, Identifiable {
    var id: String {
        "\(index)-\(content)"
    }
    let content: String
    let index: Int

}

func readTextFileAndSplitByNewline() -> [RItem] {
    if let filePath = Bundle.main.path(forResource: "chaizi-jt", ofType: "txt") {
        do {
            let fileContent = try String(contentsOfFile: filePath, encoding: .utf8)
            let lines = fileContent.components(separatedBy: .newlines)
            return lines.enumerated().map { (index, element) in
                RItem(content: element, index: index)
            }
        } catch {
            print("Error reading the file: \(error)")
        }
    } else {
        print("File not found")
    }
    return []
}


// 调用函数来读取文件和拆分文本
let lines = readTextFileAndSplitByNewline()



struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }
}




struct ContentView: View {
    @State private var searchText = ""
    @State private var filteredItems: [RItem] = lines

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(searchText: $searchText)

                List {
                    ForEach(filterItem()) { item in
                        Link(destination: getUrl(item), label: {
                            Text(item.id)
                        })
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationBarTitle("Search Example")
        }
    }

    func getUrl(_ item: RItem) -> URL {

        if let firstCharacter = item.content.first {
            let characterString = String(firstCharacter)
            if let encodedCharacter = characterString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                print("编码后的第一个字符是: \(encodedCharacter)")
                return URL(string: "https://dict.baidu.com/s?wd=\(encodedCharacter)")!
            }
        } else {
            print("字符串为空")
        }
        return URL(string: "https://dict.baidu.com")!
    }
    func filterItem() -> [RItem] {
        filteredItems.filter {
            searchText.isEmpty || $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


//import SwiftUI
//
//
//struct ContentView: View {
//    @State private var isPresented = false
//
//    var body: some View {
//        Button("显示模态窗口") {
//            // 当按钮被点击时，isPresented 的值就会被设置为 true
//            self.isPresented = true
//        }
//        .sheet(isPresented: $isPresented) {
//            InputView(isPresented: $isPresented)
////            Button("点击隐藏") {
////                // 当按钮被点击时，isPresented 的值就会被设置为 true
////                self.isPresented = false
////            }
//        }
//    }
//}
//
//struct InputView: View {
//
//    @Binding var isPresented:Bool
//
//    var body: some View {
//        Text("这是一个模态窗口")
//        Button("点击隐藏") {
//            // 当按钮被点击时，isPresented 的值就会被设置为 true
//            self.isPresented = false
//        }
//    }
//}
//
////struct Product {
////    var name: String
////    var isTaskComplete: Bool
////    let level: Int
////    mutating func toggleFavorite() {
////        isTaskComplete.toggle()
////    }
////}
////
////
////struct ProductDetailView: View {
////    @Binding var product: Product
////
////    var body: some View {
////        VStack {
////            // 显示产品详情内容
////
////            Button(action: {
////                product.toggleFavorite()
////            }) {
////                if product.isTaskComplete {
////                    Image(systemName: "star.fill")
////                        .foregroundColor(.yellow)
////                } else {
////                    Image(systemName: "star")
////                        .foregroundColor(.gray)
////                }
////            }
////        }
////    }
////}
////
////
////struct ContentView: View {
////    @State private var productList = [
////        Product(name: "Product 1", isTaskComplete: true, level: 3),
////        Product(name: "Product 2", isTaskComplete: false, level: 4),
////        Product(name: "Product 3", isTaskComplete: true, level: 5),
////    ]
////
////    var body: some View {
////        NavigationView {
////            ProductListView(products: $productList)
////        }
////    }
////}
////
////struct ProductListView: View {
////    @Binding var products: [Product]
////    let blueColor = Color(uiColor: UIColor.blue);
////    let rows = [GridItem(.fixed(20)), GridItem(.fixed(20))]
////
////    var body: some View {
////        List {
////            ForEach(products.indices, id: \.self) { index in
////                let item = products[index]
////
////                NavigationLink {
////                    ProductDetailView(product: $products[index])
////                } label: {
////                    Image("Cube")
////                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(blueColor, lineWidth: 1))
////                        .scaleEffect(CGSize(width: 1.0, height: 1.0))
////                        .disabled(true)
////                    Spacer(minLength: 12.0)
////                    VStack(alignment: .leading){
////                        Text("\(item.name)")
////                        HStack {
////                            ForEach(0..<item.level, id: \.self) { _ in
////                                Image(systemName:"star.fill").scaleEffect(CGSizeMake(0.8, 0.8)).foregroundColor(.yellow)
////                            }
////                        }
////                        if #available(iOS 16, *) {
////                            Text("\(LocalizedStringResource(stringLiteral: "\(item.isTaskComplete ? "Completed" : "ToDo")")) ")
////                            .font(.subheadline)
////                                                    +
////                        Text(Image(systemName: item.isTaskComplete ? "checkmark.circle.fill" : "checkmark.circle"))
////                            .font(.subheadline)
////                            .foregroundColor(item.isTaskComplete ? .green : .pink)
////                        } else {
////                            Text("\(item.isTaskComplete ? "Completed" : "ToDo")")
////                            .font(.subheadline)
////                                                    +
////                        Text(Image(systemName: item.isTaskComplete ? "checkmark.circle.fill" : "checkmark.circle"))
////                            .font(.subheadline)
////                            .foregroundColor(item.isTaskComplete ? .green : .pink)
////                        }
////
////                    }
////                }
////            }
////        }
////    }
////}
//
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
