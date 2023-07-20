//
//  ContentView.swift
//  CubeComplete
//
//  Created by yanguo sun on 2023/7/12.
//

import SwiftUI

struct Product {
    var name: String
    var isTaskComplete: Bool
    let level: Int
    mutating func toggleFavorite() {
        isTaskComplete.toggle()
    }
}


struct ProductDetailView: View {
    @Binding var product: Product

    var body: some View {
        VStack {
            // 显示产品详情内容

            Button(action: {
                product.toggleFavorite()
            }) {
                if product.isTaskComplete {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                } else {
                    Image(systemName: "star")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}


struct ContentView: View {
    @State private var productList = [
        Product(name: "Product 1", isTaskComplete: true, level: 3),
        Product(name: "Product 2", isTaskComplete: false, level: 4),
        Product(name: "Product 3", isTaskComplete: true, level: 5),
    ]

    var body: some View {
        NavigationView {
            ProductListView(products: $productList)
        }
    }
}

struct ProductListView: View {
    @Binding var products: [Product]
    let blueColor = Color(uiColor: UIColor.blue);
    let rows = [GridItem(.fixed(20)), GridItem(.fixed(20))]

    var body: some View {
        List {
            ForEach(products.indices, id: \.self) { index in
                let item = products[index]

                NavigationLink {
                    ProductDetailView(product: $products[index])
                } label: {
                    Image("Cube")
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(blueColor, lineWidth: 1))
                        .scaleEffect(CGSize(width: 1.0, height: 1.0))
                        .disabled(true)
                    Spacer(minLength: 12.0)
                    VStack(alignment: .leading){
                        Text("\(item.name)")
                        HStack {
                            ForEach(0..<item.level, id: \.self) { _ in
                                Image(systemName:"star.fill").scaleEffect(CGSizeMake(0.8, 0.8)).foregroundColor(.yellow)
                            }
                        }
                        Text("\(LocalizedStringResource(stringLiteral: "\(item.isTaskComplete ? "Completed" : "ToDo")")) ")
                            .font(.subheadline)
                        +
                        Text(Image(systemName: item.isTaskComplete ? "checkmark.circle.fill" : "checkmark.circle"))
                            .font(.subheadline)
                            .foregroundColor(item.isTaskComplete ? .green : .pink)
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
