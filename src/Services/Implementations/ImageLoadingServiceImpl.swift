//
//  ImageLoader.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/4/15.
//
//

import Foundation
import ReactiveCocoa
import MobileCoreServices
import ImageIO
import CoreGraphics

final class ImageLoadingServiceImpl: ImageLoadingService {
    
    private let scheduler: QueueScheduler
    
    init(qos: dispatch_qos_class_t = QOS_CLASS_DEFAULT) {
        scheduler = QueueScheduler(qos: qos, name: "com.sanekgusev.xkcd.ImageLoadingServiceImpl.queue")
    }
    
    func loadImage(fileURL: FileURL, loadingMode: ImageLoadingServiceLoadingMode, shouldCache: Bool) -> SignalProducer<CGImage, ImageLoadingServiceLoadError> {
        return SignalProducer { observer, disposable in
            guard fileURL.fileURL else {
                observer.sendFailed(.NotAFileURL)
                return
            }
            var optionsDict: Dictionary<String, String>?
            if let pathExtension = fileURL.pathExtension, UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                pathExtension,
                nil)?.takeRetainedValue() as? String {
                optionsDict = [ kCGImageSourceTypeIdentifierHint as String : UTI ]
            }
            guard let imageSource = CGImageSourceCreateWithURL(fileURL, optionsDict) else {
                observer.sendFailed(.ImageSourceCreationFailed)
                return
            }
            var options: [String: AnyObject] = [ kCGImageSourceShouldCache as String: shouldCache,
                kCGImageSourceCreateThumbnailFromImageAlways as String: true,
                kCGImageSourceCreateThumbnailWithTransform as String: true ]
            if case let .Thumbnail(maxDimension) = loadingMode {
                options[kCGImageSourceThumbnailMaxPixelSize as String] = maxDimension
            }
            
            guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, options) else {
                observer.sendFailed(.ImageCreationFailed)
                return
            }
            observer.sendNext(image)
            observer.sendCompleted()
        }.startOn(scheduler)
    }
    
    func uncompressImage(image: CGImage) -> SignalProducer<CGImage, ImageLoadingServiceUncompressionError> {
        return SignalProducer { observer, disposable in
            guard let colorSpace = CGColorSpaceCreateDeviceRGB() else {
                observer.sendFailed(.ColorSpaceCreationFailed)
                return
            }
            var bitmapInfo = CGImageGetBitmapInfo(image)
            
            let alphaInfo = CGImageAlphaInfo(rawValue: (bitmapInfo.intersect(.AlphaInfoMask)).rawValue)
            let anyNonAlpha = (alphaInfo == .None ||
                alphaInfo == .NoneSkipFirst ||
                alphaInfo == .NoneSkipLast);
            
            // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
            // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
            if (alphaInfo == .None &&
                CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
                // Unset the old alpha info.
                bitmapInfo.subtractInPlace(.AlphaInfoMask)
                
                // Set noneSkipFirst.
                bitmapInfo.unionInPlace(CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipFirst.rawValue))
            }
                // Some PNGs tell us they have alpha but only 3 components. Odd.
            else if (!anyNonAlpha &&
                CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
                // Unset the old alpha info.
                bitmapInfo.subtractInPlace(.AlphaInfoMask)
                bitmapInfo.unionInPlace(CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue))
            }
            
            let imageWidth = CGImageGetWidth(image)
            let imageHeight = CGImageGetHeight(image)
            // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
            guard let context = CGBitmapContextCreate(nil,
                imageWidth,
                imageHeight,
                CGImageGetBitsPerComponent(image),
                0,
                colorSpace,
                bitmapInfo.rawValue) else {
                    observer.sendFailed(.ContextCreationFailed)
                    return
            }
            
            let imageRect = CGRect(origin: .zero, size: CGSize(width: imageWidth,
                height: imageHeight))
            
            CGContextDrawImage(context, imageRect, image)
            guard let image = CGBitmapContextCreateImage(context) else {
                observer.sendFailed(.ImageCreationFailed)
                return
            }
            
            observer.sendNext(image)
            observer.sendCompleted()
        }.startOn(scheduler)
    }
}