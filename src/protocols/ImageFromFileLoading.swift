//
//  ImageFromFileLoading.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 7/28/15.
//
//

import Foundation
import SwiftTask
import QuartzCore

enum ImageFromFileLoadingMode {
    case FullResolution
    case Thumbnail(maxPixelSize: CGFloat)
}

protocol ImageFromFileLoading {
    func loadImageFromFileWithURL(fileURL: FileURL,
        mode: ImageFromFileLoadingMode,
        qualityOfService: NSQualityOfService) -> Task<Void, CGImage, ErrorType>
}
