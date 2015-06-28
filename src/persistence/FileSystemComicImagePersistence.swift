//
//  FileSystemComicImagePersistence.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/17/15.
//
//

import Foundation
import CoreGraphics

final class FileSystemComicImagePersistence : ComicImagePersistence,
    ComicImagePersistentDataSource {
    
    // MARK: ivar
    
    let _rootDirectoryURL: NSURL
    let _imageLoadingQueue: dispatch_queue_t
    
    // MARK: init
    
    init(rootDirectoryURL: NSURL) {
        _rootDirectoryURL = rootDirectoryURL
        _imageLoadingQueue = dispatch_queue_create("com.sanekgusev.FileSystemComicImagePersistence",
            DISPATCH_QUEUE_CONCURRENT)
        ensureDirectoryExistsAtURL(_rootDirectoryURL)
    }

    // MARK: ComicImagePersistence
    
    func persistComicImageAtURL(URL: NSURL,
        forComic comic: Comic,
        imageKind: ComicImageKind) -> Result<Void> {
            
        let imageDirectoryURL = directoryURLForComic(comic,
            imageKind: imageKind)
        let imageURL = imageDirectoryURL.URLByAppendingPathComponent(URL.lastPathComponent!)
            
        do {
            try NSFileManager.defaultManager().moveItemAtURL(URL,
                        toURL: imageURL)
        } catch let error as NSError {
            return .Failure(error)
        }
        return .Success()
    }
    
    // MARK: ComicImagePersistentDataSource
    
    func loadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        size: ComicImagePersistentDataSourceSize) -> AsynchronousTask<Result<CGImage>> {
        return AsynchronousTask<Result<CGImage>>(spawnBlock: { (completionBlock) -> () in
            if let imageFileURL = self.imageFileURLForComic(comic,
                imageKind: imageKind) {
                dispatch_async(self._imageLoadingQueue, { () -> Void in
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
                        completionBlock(result: .Success(image))
                    }
                    catch let error {
                        completionBlock(result: .Failure(error as NSError)) // TODO: fix
                    }
                })
            }
            else {
                completionBlock(result: .Failure(nil)) // TODO: add error
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
        var error: NSError?
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(directoryURL,
                        withIntermediateDirectories: true,
                        attributes: nil)
        } catch var error1 as NSError {
            error = error1
            print(error)
        }
    }
}
