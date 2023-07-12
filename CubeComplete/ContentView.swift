//
//  ContentView.swift
//  CubeComplete
//
//  Created by yanguo sun on 2023/7/12.
//

import SwiftUI

struct Product {
    var name: String
    var isFavorite: Bool

    mutating func toggleFavorite() {
        isFavorite.toggle()
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
                if product.isFavorite {
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
        Product(name: "Product 1", isFavorite: true),
        Product(name: "Product 2", isFavorite: false),
        Product(name: "Product 3", isFavorite: true)
    ]

    var body: some View {
        NavigationView {
            ProductListView(products: $productList)
        }
    }
}

struct ProductListView: View {
    @Binding var products: [Product]

    var body: some View {
        List {
            ForEach(products.indices, id: \.self) { index in
                let product = products[index]

                NavigationLink {
                    ProductDetailView(product: $products[index])
                } label: {
                    HStack {
                        Text(product.name)
                        if product.isFavorite {
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
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
