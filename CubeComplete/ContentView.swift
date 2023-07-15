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
    @State private var counter = 0
    @State private var isTimerRunning = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Text("Counter: \(counter)")
                .font(.largeTitle)
            
            Button(action: {
                isTimerRunning.toggle()
            }) {
                Text(isTimerRunning ? "暂停" : "继续")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(isTimerRunning ? Color.red : Color.green)
                    .cornerRadius(10)
            }
        }
        .onReceive(timer) { _ in
            if isTimerRunning {
                counter += 1
            }
        }
    }
    
//    @State private var age = 18 {
//        didSet {
//            print("age\(age)")
//        }
//    }
//
//    var body: some View {
//        VStack {
////            Stepper("Enter your age", value: $age, in: 0...130)
//            Stepper("显示下一步", onIncrement: {
//                         age += 1
//                     }, onDecrement: {
//                         age -= 1
//                     })
//            Text("Your age is \(age)")
//        }
//    }
//    @State private var productList = [
//        Product(name: "Product 1", isFavorite: true),
//        Product(name: "Product 2", isFavorite: false),
//        Product(name: "Product 3", isFavorite: true)
//    ]
//
//    var body: some View {
//        NavigationView {
//            ProductListView(products: $productList)
//        }
//    }
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
