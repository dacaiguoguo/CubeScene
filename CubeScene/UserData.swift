//
//  UserData.swift
//  CubeScene
//
//  Created by lvmama on 2023/7/15.
//

import Foundation
import UIKit


// 生成一次 优化效率
func generateImage(color: UIColor, text: String) -> UIImage {
    let size = CGSize(width: 100, height: 100)
    let renderer = UIGraphicsImageRenderer(size: size)
    
    let image = renderer.image { context in
        color.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 46),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]
        
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        attributedText.draw(at: CGPoint(x: 35, y: 23))
    }
    
    return image
}

func getTextImageList() -> [UIImage] {
    return Array(0...7).map { index in
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let fileURL = documentsDirectory.appendingPathComponent("blockside\(index).png")
            if let ret = UIImage(contentsOfFile: fileURL.path()) {
                return ret
            } else {
                return UIImage(named: "c1")!;
            }
        } else {
            return UIImage(named: "c1")!;
        }
    }
}


class UserData: ObservableObject {
    @Published var colorSaveList:[UIColor] {
        didSet {
            // 设置后把颜色写入文件，同时更新文字图片
            for (index, item) in colorSaveList.enumerated() {
                UserDefaults.standard.set(item.encode(), forKey: "block\(index)")
                if let imageData = generateImage(color: item, text: "\(index)").pngData(),
                   let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsDirectory.appendingPathComponent("blockside\(index).png")
                    do {
                        try imageData.write(to: fileURL)
                        print("Image saved successfully. File path: \(fileURL)")
                    } catch {
                        print("Error saving image: \(error)")
                    }
                }
            }
            // 同步修改文字图片
            self.textImageList = getTextImageList()
        }
    }
    var textImageList:[UIImage]
    
    init() {
        // 默认颜色
//        let array = [UIColor(hex: "000000"),
//                     UIColor(hex: "FF8800"),
//                     UIColor(hex: "0396FF"),
//                     UIColor(hex: "EA5455"),
//                     UIColor(hex: "7367F0"),
//                     UIColor.gray,
//                     UIColor(hex: "28C76F"),
//                     UIColor.purple];

        let array = [
            UIColor(hex: "000000"),
            UIColor(hex: "5B5B5B"),
            UIColor(hex: "C25C1D"),
            UIColor(hex: "FDC593"),
            UIColor(hex: "FA2E34"),
            UIColor(hex: "FB5BC2"),
            UIColor(hex: "FCC633"),
            UIColor(hex: "178E20")]

        // 根据颜色生成带数字的图片，写入ducument
        for (index, item) in array.enumerated() {
            UserDefaults.standard.register(defaults: ["block\(index)" : item.encode()!])
            if let imageData = generateImage(color: item, text: "\(index)").pngData(),
               let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent("blockside\(index).png")
                do {
                    try imageData.write(to: fileURL)
                    print("Image saved successfully. File path: \(fileURL)")
                } catch {
                    print("Error saving image: \(error)")
                }
            }
        }
        // 赋值
        self.colorSaveList = Array(0...7).map { index in
            if let data = UserDefaults.standard.data(forKey: "block\(index)") {
                return UIColor.decode(data: data) ?? UIColor.purple
            } else {
                return UIColor.orange;
            }
        }
        // 赋值图片
        self.textImageList = getTextImageList()
    }
}
