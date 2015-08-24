//
//  ImageFileLoadingImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 7/29/15.
//
//

import Foundation
import SwiftTask
import QuartzCore

// TODO: use Async

final class ImageFromFileLoadingImpl: ImageFromFileLoading {
    
    // MARK: Properties
    
    private let backgroundQueue: dispatch_queue_t
    
    // MARK: Init
    
    init(backgroundQueueQualityOfService: NSQualityOfService) {
        self.backgroundQueue = dispatch_queue_create("com.sanekgusev.xkcd.ImageFromFileLoadingImpl",
            dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT,
                dispatch_qos_class_t(UInt32(backgroundQueueQualityOfService.rawValue)),
                0))
    }
    
    // MARK: ImageFromFileLoading
    
    func loadImageFromFileWithURL(fileURL: NSURL,
        mode: ImageFromFileLoadingMode,
        qualityOfService: NSQualityOfService) -> Task<Void, CGImage, ErrorType> {
            return Task<Void, CGImage, ErrorType>(weakified: false, paused: true,
                initClosure: { (progress, fulfill, reject, configure) -> Void in
                    let dispatchBlock = dispatch_block_create_with_qos_class(dispatch_block_flags_t(0),
                        dispatch_qos_class_t(UInt32(qualityOfService.rawValue)),
                        0, {
                            do {
                                let loadingMode: ImageLoading.LoadingMode
                                switch mode {
                                case .FullResolution:
                                    loadingMode = .FullResolution
                                case .Thumbnail(let maxPixelSize):
                                    loadingMode = .Thumbnail(maxDimension:maxPixelSize)
                                }
                                let image = try ImageLoading.loadImage(fileURL,
                                    loadingMode: loadingMode)
                                fulfill(image)
                            }
                            catch let error {
                                reject(error)
                            }
                    })
                    configure.resume = {
                        dispatch_async(self.backgroundQueue, dispatchBlock)
                    }
                    configure.cancel = {
                        dispatch_block_cancel(dispatchBlock)
                    }
            })
    }
}
