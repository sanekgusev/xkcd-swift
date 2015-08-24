//
//  ComicImageLoadingCoordinatorImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 7/29/15.
//
//

import Foundation
import SwiftTask
import QuartzCore

final class ComicImageLoadingCoordinatorImpl : ComicImageLoadingCoordinator {
    
    // MARK: properties
    
    private let imagePersistence: ComicImagePersistence
    private let imagePersistentDataSource: ComicImagePersistentDataSource
    private let imageLoading: ImageFromFileLoading
    private let imageNetworkDataSource: ComicImageNetworkDataSource
    
    // MARK: init
    
    init(imagePersistence: ComicImagePersistence,
        imagePersistentDataSource: ComicImagePersistentDataSource,
        imageLoading: ImageFromFileLoading,
        imageNetworkDataSource: ComicImageNetworkDataSource) {
            self.imagePersistence = imagePersistence
            self.imagePersistentDataSource = imagePersistentDataSource
            self.imageLoading = imageLoading
            self.imageNetworkDataSource = imageNetworkDataSource
    }
    
    // MARK: ComicImageLoadingCoordinator
    
    func downloadAndPersistIfMissingImageForComic(comic: Comic,
        imageKind: ComicImageKind) -> Task<Float, Void, ErrorType> {
            return Task<Float, Void, ErrorType>(weakified: false, paused: true,
                initClosure: { (progress, fulfill, reject, configure) -> Void in
                    let checkPersistedTask = self.imagePersistentDataSource.getImageFileURLForComic(comic,
                        imageKind: imageKind,
                        qualityOfService: .Background)
                    var downloadTask: Task<Float, NSURL, ErrorType>?
                    checkPersistedTask.then({ (imageFileURL, errorInfo) -> Void in
                        if let _ = imageFileURL {
                            fulfill()
                            return
                        }
                        do {
                            downloadTask = try self.imageNetworkDataSource.downloadImageForComic(comic,
                                imageKind: imageKind)
                            downloadTask?.progress({ (oldProgress, newProgress) -> Void in
                                progress(newProgress)
                            })
                            downloadTask?.then({ (imageFileURL, errorInfo) -> Void in
                                guard let imageFileURL = imageFileURL else {
                                    reject(errorInfo!.error!)
                                    return
                                }
                                do {
                                    try self.imagePersistence.persistComicImageAtURL(imageFileURL,
                                        forComic: comic,
                                        imageKind: imageKind)
                                    fulfill()
                                }
                                catch let error {
                                    reject(error)
                                }
                            })
                            downloadTask?.resume()
                        }
                        catch let error {
                            reject(error)
                        }
                    })
                    configure.resume = {
                        checkPersistedTask.resume()
                    }
                    configure.cancel = {
                        downloadTask?.cancel()
                    }
            })
    }
    
    func downloadPersistAndLoadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        mode: ComicImageLoadingCoordinatorMode) -> Task<Float, CGImage, ErrorType> {
            return Task<Float, CGImage, ErrorType>(weakified: false, paused: true,
                initClosure: { (progress, fulfill, reject, configure) -> Void in
                    do {
                        let downloadTask = try self.imageNetworkDataSource.downloadImageForComic(comic,
                            imageKind: imageKind)
                        downloadTask.progress({ (oldProgress, newProgress) -> Void in
                            progress(newProgress)
                        })
                        downloadTask.then({ (imageFileURL, errorInfo) -> Void in
                            guard let imageFileURL = imageFileURL else {
                                reject(errorInfo!.error!)
                                return
                            }
                            do {
                                let persistedImageFileURL = try self.imagePersistence.persistComicImageAtURL(imageFileURL,
                                    forComic: comic,
                                    imageKind: imageKind)
                                let imageFromFileLoadingMode: ImageFromFileLoadingMode;
                                switch mode {
                                case .FullResolution:
                                    imageFromFileLoadingMode = .FullResolution
                                case .Thumbnail(let maxPixelSize):
                                    imageFromFileLoadingMode = .Thumbnail(maxPixelSize: maxPixelSize)
                                }
                                
                                let loadTask = self.imageLoading.loadImageFromFileWithURL(persistedImageFileURL,
                                    mode: imageFromFileLoadingMode,
                                    qualityOfService: .UserInteractive)
                                
                                
                                
                                loadTask.resume()
                            }
                            catch let error {
                                reject(error)
                            }
                        })
                        
                        configure.resume = {
                            downloadTask.resume()
                        }
                        configure.cancel = {
                            downloadTask.cancel()
                        }
                    }
                    catch let error {
                        reject(error)
                    }
            })
    }
    
    func loadStoredOrDownloadPersistAndLoadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        mode: ComicImageLoadingCoordinatorMode) -> Task<Float, CGImage, ErrorType> {
            return Task<Float, CGImage, ErrorType>(weakified: false, paused: true,
                initClosure: { (progress, fulfill, reject, configure) -> Void in
                    
            })
    }
    
}
