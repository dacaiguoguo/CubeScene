//
//  main.swift
//  ResizeVideo
//
//  Created by lvmama on 2023/7/15.
//

import Foundation
import AVFoundation

import AVFoundation

func resizeVideo(inputURL: URL, outputURL: URL, newSize: CGSize, completion: @escaping (Error?) -> Void) {
    let asset = AVAsset(url: inputURL)
    
    guard let videoTrack = asset.tracks(withMediaType: .video).first else {
        let error = NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get video track"])
        completion(error)
        return
    }
    
    let composition = AVMutableComposition()
    let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    do {
        try compositionVideoTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: asset.duration), of: videoTrack, at: CMTime.zero)
    } catch {
        completion(error)
        return
    }
    
    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = newSize
    videoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
    
    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: composition.duration)
    
    let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: compositionVideoTrack!)
    
    // 计算缩放比例
    let xScale = newSize.width / videoTrack.naturalSize.width
    let yScale = newSize.height / videoTrack.naturalSize.height
    
    // 应用缩放变换
    let scaleTransform = CGAffineTransform(scaleX: xScale, y: yScale)
    layerInstruction.setTransform(scaleTransform, at: CMTime.zero)
    
    instruction.layerInstructions = [layerInstruction]
    videoComposition.instructions = [instruction]
    
    guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
        let error = NSError(domain: "com.example", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create AVAssetExportSession"])
        completion(error)
        return
    }
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = AVFileType.mp4
    exportSession.videoComposition = videoComposition
    
    exportSession.exportAsynchronously {
        if let error = exportSession.error {
            completion(error)
            exit(1)
        } else {
            completion(nil)
            exit(0)
        }
    }
}


let inputURL = URL(fileURLWithPath: "/Users/lvmama/Developer/ResizeVideo/ResizeVideo/input.mp4")
let outputURL = URL(fileURLWithPath: "/Users/lvmama/Developer/ResizeVideo/ResizeVideo/output.mp4")
let newSize = CGSize(width: 886, height: 1920)

resizeVideo(inputURL: inputURL, outputURL: outputURL, newSize: newSize) { error in
    if let error = error {
        print("Error: \(error.localizedDescription)")
    } else {
        print("Video resizing completed successfully.")
    }
}

// 创建一个 RunLoop 并启动循环
let runLoop = RunLoop.current
runLoop.run()
