//
//  ImageLoadingService.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 09/05/16.
//
//

import Foundation
import CoreGraphics
import ReactiveCocoa

enum ImageLoadingServiceLoadingMode {
    case FullResolution
    case Thumbnail(maxDimension: CGFloat)
}

enum ImageLoadingServiceLoadError: ErrorType {
    case NotAFileURL
    case ImageSourceCreationFailed
    case ImageCreationFailed
}

enum ImageLoadingServiceUncompressionError : ErrorType {
    case ColorSpaceCreationFailed
    case ContextCreationFailed
    case ImageCreationFailed
}

protocol ImageLoadingService {
    func loadImage(fileURL: FileURL, loadingMode: ImageLoadingServiceLoadingMode, shouldCache: Bool) -> SignalProducer<CGImage, ImageLoadingServiceLoadError>
    
    func uncompressImage(image: CGImage) -> SignalProducer<CGImage, ImageLoadingServiceUncompressionError>
}


