//
//  ComicLoadingCoordinatorImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/17/15.
//
//

import Foundation

final class ComicLoadingCoordinatorImpl : ComicLoadingCoordinator {
    
    // MARK: ivars
    
    private let _concurrentTaskQueue = LimitedConcurrentTaskQueue<Result<Comic>>()
    private let _comicNetworkDataSource: ComicNetworkDataSource
    private let _comicPersistence: ComicPersistence
    
    // MARK: init
    
    init(comicNetworkDataSource: ComicNetworkDataSource,
        comicPersistence: ComicPersistence) {
        _comicNetworkDataSource = comicNetworkDataSource
        _comicPersistence = comicPersistence
    }
    
    // MARK: public
    
    var maxConcurrentDownloadsCount: Int? {
        get {
            return _concurrentTaskQueue.maxConcurrentTaskCount
        }
        set {
            _concurrentTaskQueue.maxConcurrentTaskCount = newValue
        }
    }
    
    // MARK: ComicLoadingCoordinator
    
    func downloadAndPersistComicOfKind(kind: ComicKind,
            qualityOfService: NSQualityOfService) -> CancellableAsynchronousTask<Result<Comic>> {
        let downloadTask = _comicNetworkDataSource.downloadComicOfKind(kind)
        let downloadAndPersistTask = CancellableAsynchronousTask<Result<Comic>>(spawnBlock: { (completionBlock) -> () in
            downloadTask.addResultObserverWithHandler({ (result) -> () in
                switch result {
                    case .Success(let comic):
                        let persistTask = self._comicPersistence.persistComic(comic)
                        persistTask.addResultObserverWithHandler( { (result) -> () in
                            switch result {
                                case .Failure(let error) :
                                    print(error)
                                default: ()
                            }
                        })
                        persistTask.start()
                    default: ()
                }
                completionBlock(result: result)
            })
            downloadTask.start()
        }) { () -> () in
            downloadTask.cancel()
        }
        return _concurrentTaskQueue.taskForEnqueueingTask(downloadAndPersistTask,
            queuePriority: .Normal,
            qualityOfService: qualityOfService)
    }
    
}