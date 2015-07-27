//
//  FileSystemComicImagePersistence.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/17/15.
//
//

import Foundation
import CoreGraphics
import SwiftTask

final class FileSystemComicImagePersistence : ComicImagePersistence,
    ComicImagePersistentDataSource {
    
    // MARK: errors
    
    enum Error : ErrorType {
        case FailedToGetImageFileName
        case NoPersistedImageForComic
    }
    
    // MARK: ivar
    
    private let _rootDirectoryURL: NSURL
    private lazy var _imageLoadingQueue : NSOperationQueue = {
        let operationQueue = NSOperationQueue()
        operationQueue.name = "com.sanekgusev.FileSystemComicImagePersistence"
        return operationQueue
    }()
    
    // MARK: init
    
    init(rootDirectoryURL: NSURL) {
        _rootDirectoryURL = rootDirectoryURL
        ensureDirectoryExistsAtURL(_rootDirectoryURL)
    }

    // MARK: ComicImagePersistence
    
    func persistComicImageAtURL(URL: NSURL,
        forComic comic: Comic,
        imageKind: ComicImageKind) throws {
            let imageDirectoryURL = directoryURLForComic(comic,
                imageKind: imageKind)
            guard let imageFileName = URL.lastPathComponent else {
                throw Error.FailedToGetImageFileName
            }
            let imageURL = imageDirectoryURL.URLByAppendingPathComponent(imageFileName)
            try NSFileManager.defaultManager().moveItemAtURL(URL,
                toURL: imageURL)
    }
    
    // MARK: ComicImagePersistentDataSource
    
    func loadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        size: ComicImagePersistentDataSourceSize,
        priority: NSOperationQueuePriority,
        qualityOfService: NSQualityOfService) -> Task<Float, CGImage, ErrorType> {
            return Task(weakified: false, paused: true,
                initClosure: { (progress, fulfill, reject, configure) -> Void in
                    let operation = NSBlockOperation(block: { () -> Void in
                        guard let imageFileURL = self.imageFileURLForComic(comic,
                            imageKind: imageKind) else {
                                reject(Error.NoPersistedImageForComic)
                                return
                        }
                        let loadingMode: ImageLoading.LoadingMode
                        switch size {
                        case .FullResolution:
                            loadingMode = .FullResolution
                        case .Thumbnail(let maxPixelSize):
                            loadingMode = .Thumbnail(maxDimension:maxPixelSize)
                        }
                        do {
                            let image = try ImageLoading.loadImage(imageFileURL,
                                loadingMode: loadingMode,
                                shouldCache: true)
                            fulfill(image)
                        }
                        catch let error as NSError {
                            reject(error)
                        }
                        catch {
                            fatalError()
                        }
                    })
                    operation.queuePriority = priority
                    operation.qualityOfService = qualityOfService
                    configure.resume = {
                        self._imageLoadingQueue.addOperation(operation)
                    }
                    configure.cancel = {
                        operation.cancel()
                    }
            })
    }
    
    // MARK: private
    
    private func directoryURLForComic(comic: Comic, imageKind: ComicImageKind) -> NSURL {
        let result: NSURL
        let comicDirectoryURL = _rootDirectoryURL.URLByAppendingPathComponent("\(comic.number)")
        switch imageKind {
            case .DefaultImage:
                result = comicDirectoryURL
            // TODO: other image kinds
        }
        ensureDirectoryExistsAtURL(result)
        return result
    }
    
    private func imageFileURLForComic(comic: Comic, imageKind: ComicImageKind) -> NSURL? {
        let directoryURL = directoryURLForComic(comic, imageKind: imageKind)
        if let directoryEnumerator = NSFileManager.defaultManager().enumeratorAtURL(directoryURL,
        includingPropertiesForKeys: nil,
        options: .SkipsSubdirectoryDescendants,
        errorHandler: nil) {
            if let relativeFilePath = directoryEnumerator.nextObject() as? String {
                return directoryURL.URLByAppendingPathComponent(relativeFilePath)
            }
        }
        return nil
    }
    
    private func ensureDirectoryExistsAtURL(directoryURL: NSURL) {
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(directoryURL,
                        withIntermediateDirectories: true,
                        attributes: nil)
        } catch let error as NSError {
            // TODO: check error and possibly rethrow
            print(error)
        }
    }
}
