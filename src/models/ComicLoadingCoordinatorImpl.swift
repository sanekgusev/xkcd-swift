//
//  ComicLoadingCoordinatorImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/17/15.
//
//

import Foundation
import SwiftTask

final class ComicLoadingCoordinatorImpl : ComicLoadingCoordinator {
    
    // MARK: ivars
    
    private lazy var concurrentTaskQueue = LimitedConcurrentTaskQueue<Float, Comic, ErrorType>()
    private let comicNetworkDataSource: ComicNetworkDataSource
    private let comicPersistence: ComicPersistence
    private let comicPersistentDataSource: ComicPersistentDataSource
    
    // MARK: init
    
    init(comicNetworkDataSource: ComicNetworkDataSource,
        comicPersistence: ComicPersistence,
        comicPersistentDataSource: ComicPersistentDataSource) {
            self.comicNetworkDataSource = comicNetworkDataSource
            self.comicPersistence = comicPersistence
            self.comicPersistentDataSource = comicPersistentDataSource
    }
    
    // MARK: public
    
    var maxConcurrentDownloadsCount: Int? {
        get {
            return concurrentTaskQueue.maxConcurrentTaskCount
        }
        set {
            concurrentTaskQueue.maxConcurrentTaskCount = newValue
        }
    }
    
    var maxDownloadQueueLength: Int? {
        get {
            return concurrentTaskQueue.maxQueueLength
        }
        set {
            concurrentTaskQueue.maxQueueLength = newValue
        }
    }
    
    var qualityOfService: NSQualityOfService {
        get {
            return concurrentTaskQueue.qualityOfService
        }
        set {
            concurrentTaskQueue.qualityOfService = newValue
        }
    }
    
    // MARK: ComicLoadingCoordinator
    
    func downloadAndPersistComicOfKind(kind: ComicKind) -> Task<Float, Comic, ErrorType> {
        let downloadTask = comicNetworkDataSource.downloadComicOfKind(kind)
        let downloadAndPersistTask = downloadTask.success { comic -> Comic in
            let persistTask = self.comicPersistence.persistComic(comic)
            persistTask.resume()
            return comic
        }
        return try! concurrentTaskQueue.taskForEnqueueingTask(downloadAndPersistTask)
    }
}