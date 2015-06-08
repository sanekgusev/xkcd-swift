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

final class ImageLoading {
    
    enum LoadingMode {
        case FullResolution
        case Thumbnail(maxDimension: CGFloat)
    }
    
    class func loadImage(fileURL: NSURL, loadingMode: LoadingMode, shouldCache: Bool = true) -> CGImage? {
        assert(fileURL.fileURL, "fileURL should be a file URL");
        let UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
            fileURL.pathExtension,
            nil)
        let imageSource = CGImageSourceCreateWithURL(fileURL,
            UTI == nil ? nil : [ kCGImageSourceTypeIdentifierHint as! String: UTI.takeRetainedValue() ])
        var options: [String: AnyObject] = [ kCGImageSourceShouldCache as! String: shouldCache,
            kCGImageSourceCreateThumbnailFromImageAlways as! String: true,
            kCGImageSourceCreateThumbnailWithTransform as! String: true ]
        switch loadingMode {
            case .Thumbnail(maxDimension: let maxDimension):
                options[kCGImageSourceThumbnailMaxPixelSize as! String!] = maxDimension
            default:()
        }

        return CGImageSourceCreateImageAtIndex(imageSource, 0, options)
    }
    
    class func uncompressImage(image: CGImage) -> CGImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo = CGImageGetBitmapInfo(image)
        
        let alphaInfo = CGImageAlphaInfo(rawValue: (bitmapInfo & CGBitmapInfo.AlphaInfoMask).rawValue)
        let anyNonAlpha = (alphaInfo == CGImageAlphaInfo.None ||
            alphaInfo == CGImageAlphaInfo.NoneSkipFirst ||
            alphaInfo == CGImageAlphaInfo.NoneSkipLast);
        
        // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
        // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
        if (alphaInfo == CGImageAlphaInfo.None &&
            CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
            // Unset the old alpha info.
            bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask
            
            // Set noneSkipFirst.
            bitmapInfo |= CGBitmapInfo(rawValue: CGImageAlphaInfo.NoneSkipFirst.rawValue)
        }
            // Some PNGs tell us they have alpha but only 3 components. Odd.
        else if (!anyNonAlpha &&
            CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
            // Unset the old alpha info.
            bitmapInfo &= ~CGBitmapInfo.AlphaInfoMask
            bitmapInfo |= CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        }
        
        let imageWidth = CGImageGetWidth(image)
        let imageHeight = CGImageGetHeight(image)
        // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
        let context = CGBitmapContextCreate(nil,
            imageWidth,
            imageHeight,
            CGImageGetBitsPerComponent(image),
            0,
            colorSpace,
            bitmapInfo);
        
        if (context == nil) {
            return nil
        }
        
        let imageRect = CGRect(origin: CGPoint.zeroPoint, size: CGSize(width: Int(imageWidth),
            height: Int(imageHeight)))
        
        CGContextDrawImage(context, imageRect, image)
        return CGBitmapContextCreateImage(context)
    }
}