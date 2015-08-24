//
//  FileSystemComicImagePersistence.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/17/15.
//
//

import Foundation
import SwiftTask

// TODO: use Async

final class FileSystemComicImagePersistence : ComicImagePersistence,
    ComicImagePersistentDataSource {
    
    // MARK: errors
    
    enum Error : ErrorType {
        case FailedToGetImageFileName
        case NoPersistedImageForComic
    }
    
    // MARK: ivar
    
    private let rootDirectoryURL: NSURL
    private let backgroundQueue: dispatch_queue_t
    
    // MARK: init
    
    init(rootDirectoryURL: NSURL,
        backgroundQueueQualityOfService: NSQualityOfService) {
            self.rootDirectoryURL = rootDirectoryURL
            self.backgroundQueue = dispatch_queue_create("com.sanekgusev.xkcd.FileSystemComicImagePersistence",
                dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT,
                    dispatch_qos_class_t(UInt32(backgroundQueueQualityOfService.rawValue)), 0))
            dispatch_barrier_async(self.backgroundQueue, {
                self.ensureDirectoryExistsAtURL(rootDirectoryURL)
            })
    }

    // MARK: ComicImagePersistence
    
    func persistComicImageAtURL(URL: NSURL,
        forComic comic: Comic,
        imageKind: ComicImageKind) throws -> NSURL {
            let imageDirectoryURL = directoryURLForComic(comic,
                imageKind: imageKind)
            guard let imageFileName = URL.lastPathComponent else {
                throw Error.FailedToGetImageFileName
            }
            var error: ErrorType?
            var resultImageURL: NSURL?
            dispatch_barrier_sync(self.backgroundQueue, {
                self.ensureDirectoryExistsAtURL(imageDirectoryURL)
                let imageURL = imageDirectoryURL.URLByAppendingPathComponent(imageFileName)
                resultImageURL = imageURL
                do {
                    try NSFileManager.defaultManager().moveItemAtURL(URL,
                        toURL: imageURL)
                }
                catch let anError {
                    error = anError
                }
            })
            guard let aResultImageURL = resultImageURL else {
                throw error!
            }
            return aResultImageURL
    }
    
    // MARK: ComicImagePersistentDataSource
    
    func getImageFileURLForComic(comic: Comic,
        imageKind: ComicImageKind,
        qualityOfService: NSQualityOfService) -> Task<Void, NSURL, ErrorType> {
            return Task(weakified: false, paused: true,
                initClosure: { (progress, fulfill, reject, configure) -> Void in
                    let dispatchBlock = dispatch_block_create_with_qos_class(dispatch_block_flags_t(0),
                        dispatch_qos_class_t(UInt32(qualityOfService.rawValue)),
                        0,
                        {
                            guard let imageFileURL = self.imageFileURLForComic(comic,
                                imageKind: imageKind) else {
                                    reject(Error.NoPersistedImageForComic)
                                    return
                            }
                            fulfill(imageFileURL)
                    })
                    configure.resume = {
                        dispatch_async(self.backgroundQueue, dispatchBlock)
                    }
                    configure.cancel = {
                        dispatch_block_cancel(dispatchBlock)
                    }
            })
    }
    
    // MARK: private
    
    private func directoryURLForComic(comic: Comic, imageKind: ComicImageKind) -> NSURL {
        let result: NSURL
        let comicDirectoryURL = rootDirectoryURL.URLByAppendingPathComponent("\(comic.number)")
        switch imageKind {
            case .DefaultImage:
                result = comicDirectoryURL
            // TODO: other image kinds
        }
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
