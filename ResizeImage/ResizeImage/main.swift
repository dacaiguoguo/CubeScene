//
//  main.swift
//  ResizeImage
//
//  Created by lvmama on 2023/7/17.
//

import Foundation
import AppKit

func resizeImage(inputImagePath:String, outputImagePath:String, cropRectString:String) -> Void {

    // 解析裁剪矩形
    let rectComponents = cropRectString.components(separatedBy: ",").compactMap { Double($0) }
    guard rectComponents.count == 4 else {
        print("Invalid crop rectangle format. Expected format: x,y,width,height")
        exit(1)
    }

    let cropRect = NSRect(x: rectComponents[0], y: rectComponents[1], width: rectComponents[2], height: rectComponents[3])

    // 加载输入图片
    guard let inputImage = NSImage(contentsOfFile: inputImagePath) else {
        print("Failed to load input image at path: \(inputImagePath)")
        exit(1)
    }

    // 创建裁剪后的图像
    let outputImage = NSImage(size: cropRect.size)
    outputImage.lockFocus()
    print(inputImage.size)

    inputImage.draw(in: NSRect(origin: .zero, size: cropRect.size), from: cropRect, operation: .copy, fraction: 1.0)
    outputImage.unlockFocus()

    // 将图像保存到输出路径

    guard let imageData = outputImage.tiffRepresentation,let bitmapRep = NSBitmapImageRep(data: imageData) else {
        print("Failed to create bitmap representation of the output image.")
        exit(1)
    }

    guard let jpegData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("Failed to convert output image to JPEG format.")
        exit(1)
    }

    do {
        try jpegData.write(to: URL(fileURLWithPath: outputImagePath))
        print("Image cropped and saved successfully.")
    } catch {
        print("Failed to save output image: \(error)")
        exit(1)
    }
}

let dir = "/Users/sunyanguo/Developer/CubeScene/CubeScene/AImages"
let todir = "/Users/sunyanguo/Developer/ResizeImage/ResizeImage"

let list = try! FileManager.default.contentsOfDirectory(atPath: dir)
for testString in list {
    if testString.hasSuffix(".png") {
        let startIndex = (testString as NSString).deletingPathExtension
        let onename = "\(todir)/\(startIndex)@3x.png"
        print(onename)
        do {
            try FileManager.default.copyItem(atPath: "\(dir)/\(testString)", toPath: onename)
        } catch {
            print(error)
        }
    }
//    if testString.hasSuffix("@3x.png") {
//        let startIndex = testString.index(testString.startIndex, offsetBy: 0)
//        let endIndex = testString.index(testString.endIndex, offsetBy: -7)
//        let onename = "\(todir)/\(testString[startIndex ..< endIndex]).png"
//        print(onename)
//        do {
//            try FileManager.default.copyItem(atPath: "/Users/sunyanguo/Developer/ResizeImage/ResizeImage/todoimages/\(testString)", toPath: onename)
//        } catch {
//            print(error)
//        }
//    }

}

//print(list)
//for testString in list {
//    if (testString as NSString).pathExtension == "png" {
//        let inputImagePath = "\(dir)/\(testString)"
//        let outputImagePath = "\(todir)/\((testString as NSString).deletingPathExtension)@3x.png"
//        let cropRectString = "0,550,950,950"
//        resizeImage(inputImagePath: inputImagePath, outputImagePath: outputImagePath, cropRectString: cropRectString)
//    }
//}
