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

enum ImageLoadingServiceError: ErrorType {
    case NotAFileURL
    case UTICreationFailed
    case ImageSourceCreationFailed
    case ImageCreationFailed
}

protocol ImageLoadingService {
    func loadImage(fileURL: FileURL, loadingMode: ImageLoadingServiceLoadingMode, shouldCache: Bool) -> SignalProducer<CGImage, ImageLoadingServiceError>
}


