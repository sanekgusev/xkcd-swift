//
//  ImageLoader.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/4/15.
//
//

import Foundation
import MobileCoreServices
import ImageIO
import CoreGraphics

final class ImageLoadingServiceImpl {
    
    enum LoadingMode {
        case FullResolution
        case Thumbnail(maxDimension: CGFloat)
    }
    
    enum ImageLoadingError : ErrorType {
        case NotAFileURL
        case UTICreationFailed
        case ImageSourceCreationFailed
        case ImageCreationFailed
    }
    
    func loadImage(fileURL: NSURL, loadingMode: LoadingMode, shouldCache: Bool = true) throws -> CGImage {
        guard fileURL.fileURL, let pathExtension = fileURL.pathExtension else {
            throw ImageLoadingError.NotAFileURL
        }
        guard let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
            pathExtension,
            nil)?.takeRetainedValue() as? String else {
            throw ImageLoadingError.UTICreationFailed
        }
        guard let imageSource = CGImageSourceCreateWithURL(fileURL,
            [ kCGImageSourceTypeIdentifierHint as String : UTI ]) else {
                throw ImageLoadingError.ImageSourceCreationFailed
        }
        var options: [String: AnyObject] = [ kCGImageSourceShouldCache as String: shouldCache,
            kCGImageSourceCreateThumbnailFromImageAlways as String: true,
            kCGImageSourceCreateThumbnailWithTransform as String: true ]
        switch loadingMode {
            case .Thumbnail(maxDimension: let maxDimension):
                options[kCGImageSourceThumbnailMaxPixelSize as String] = maxDimension
            default:()
        }

        guard let image = CGImageSourceCreateImageAtIndex(imageSource, 0, options) else {
            throw ImageLoadingError.ImageCreationFailed
        }
        return image
    }
    
    enum ImageUncompressionError : ErrorType {
        case ColorSpaceCreationFailed
        case ContextCreationFailed
        case ImageCreationFailed
    }
    
    class func uncompressImage(image: CGImage) throws -> CGImage {
        guard let colorSpace = CGColorSpaceCreateDeviceRGB() else {
            throw ImageUncompressionError.ColorSpaceCreationFailed
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
                throw ImageUncompressionError.ContextCreationFailed
        }
        
        let imageRect = CGRect(origin: .zero, size: CGSize(width: imageWidth,
            height: imageHeight))
        
        CGContextDrawImage(context, imageRect, image)
        guard let image = CGBitmapContextCreateImage(context) else {
            throw ImageUncompressionError.ImageCreationFailed
        }
        
        return image
    }
}