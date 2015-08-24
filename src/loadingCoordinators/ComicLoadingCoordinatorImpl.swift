//
//  ComicLoadingCoordinatorImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/17/15.
//
//

import Foundation
import SwiftTask
import Result

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
        return Task<Float, Comic, ErrorType>(weakified: false,
            paused: true) { (progress, fulfill, reject, configure) -> Void in
                let downloadTask = self.comicNetworkDataSource.downloadComicOfKind(kind)
                let queuedDownloadTask = try! self.concurrentTaskQueue.taskForEnqueueingTask(downloadTask)
                queuedDownloadTask.progress({ (oldProgress, newProgress) -> Void in
                    progress(newProgress)
                })
                queuedDownloadTask.then { (comic, errorInfo) -> Void in
                    guard let comic = comic else {
                        reject(errorInfo!.error! as NSError)
                        return
                    }
                    let persistTask = self.comicPersistence.persistComic(comic)
                    persistTask.then({ (_, errorInfo) -> Void in
                        print(errorInfo)
                    })
                    persistTask.resume()
                    fulfill(comic)
                }
                configure.resume = {
                    queuedDownloadTask.resume()
                }
                configure.cancel = {
                    queuedDownloadTask.cancel()
                }
        }
    }
    
    func loadOrDownloadAndPersistComicsWithNumbers(numbers: Set<Int>) -> Task<Result<Comic, NSError>, Void, Void> {
        let resultTask = Task<Result<Comic, NSError>, Void, Void>(weakified: false,
            paused: true) { (progress, fulfill, reject, configure) -> Void in
                let loadTask = self.comicPersistentDataSource.loadComicsWithNumbers(numbers)
                var queuedDownloadTasks = [Task<Float, Comic, ErrorType>]()
                loadTask.then { (comicCollection, errorInfo) -> Void in
                    if let errorInfo = errorInfo {
                        if errorInfo.isCancelled {
                            return;
                        }
                    }
                    let numbersOfComicsToDownload: Set<Int>
                    if let comicCollection = comicCollection {
                        numbersOfComicsToDownload = numbers.subtract(comicCollection.keys)
                        for (_, comic) in comicCollection {
                            progress(Result(value: comic))
                        }
                    }
                    else {
                        numbersOfComicsToDownload = numbers
                    }
                    if numbersOfComicsToDownload.isEmpty {
                        fulfill()
                    }
                    for comicNumber in numbersOfComicsToDownload {
                        let downloadTask = self.comicNetworkDataSource.downloadComicOfKind(.ByNumber(comicNumber))
                        let queuedDownloadTask = try! self.concurrentTaskQueue.taskForEnqueueingTask(downloadTask)
                        queuedDownloadTask.then({ (comic: Comic?, errorInfo: Task.ErrorInfo?) -> Void in
                            progress(Result(comic, failWith: errorInfo!.error! as NSError))
                            guard let comic = comic else {
                                print(errorInfo)
                                return
                            }
                            let persistTask = self.comicPersistence.persistComic(comic)
                            persistTask.failure { errorInfo -> Void in
                                print(errorInfo)
                            }
                            persistTask.resume()
                        })
                        queuedDownloadTasks.append(queuedDownloadTask)
                        queuedDownloadTask.resume()
                    }
                    Task.some(queuedDownloadTasks).success({ comics -> Void in
                        if comics.count == numbersOfComicsToDownload.count {
                            fulfill()
                        }
                        else {
                            reject()
                        }
                    })
                }
                configure.resume = {
                    loadTask.resume()
                }
                configure.cancel = {
                    loadTask.cancel()
                    Task.cancelAll(queuedDownloadTasks)
                }
        }
        return resultTask
    }
    
    func downloadAndPersistNotPersitedComicsWithNumbers(numbers: Set<Int>) -> Task<Result<Int, NSError>, Void, Void> {
        let resultTask = Task<Result<Int, NSError>, Void, Void>(weakified: false,
            paused: true) { (progress, fulfill, reject, configure) -> Void in
                let loadTask = self.comicPersistentDataSource.fetchPersistedComicNumbers(numbers)
                var queuedDownloadTasks = [Task<Float, Comic, ErrorType>]()
                var persistTasks = [Task<Void, Void, ErrorType>]()
                loadTask.then { (persistedComicNumbers, errorInfo) -> Void in
                    if let errorInfo = errorInfo {
                        if errorInfo.isCancelled {
                            return;
                        }
                    }
                    let numbersOfComicsToDownload: Set<Int>
                    if let persistedComicNumbers = persistedComicNumbers {
                        numbersOfComicsToDownload = numbers.subtract(persistedComicNumbers)
                        for comicNumber in persistedComicNumbers {
                            progress(Result(value: comicNumber))
                        }
                    }
                    else {
                        numbersOfComicsToDownload = numbers
                    }
                    if numbersOfComicsToDownload.isEmpty {
                        fulfill()
                    }
                    for comicNumber in numbersOfComicsToDownload {
                        let downloadTask = self.comicNetworkDataSource.downloadComicOfKind(.ByNumber(comicNumber))
                        let queuedDownloadTask = try! self.concurrentTaskQueue.taskForEnqueueingTask(downloadTask)
                        queuedDownloadTask.then({ (comic, errorInfo) -> Void in
                            guard let comic = comic else {
                                progress(Result(error: errorInfo!.error! as NSError))
                                return
                            }
                            let persistTask = self.comicPersistence.persistComic(comic)
                            persistTask.then { (_, errorInfo: Task.ErrorInfo?) -> Void in
                                if let errorInfo = errorInfo {
                                    progress(Result(error: errorInfo.error! as NSError))
                                }
                                else {
                                    progress(Result(value: comicNumber))
                                }
                            }
                            persistTasks.append(persistTask)
                            persistTask.resume()
                        })
                        queuedDownloadTasks.append(queuedDownloadTask)
                        queuedDownloadTask.resume()
                    }
                    Task.some(queuedDownloadTasks).success({ comics -> Void in
                        Task.some(persistTasks).success({ results -> Void in
                            if results.count == numbersOfComicsToDownload.count {
                                fulfill()
                            }
                            else {
                                reject()
                            }
                        })
                    })
                }
                configure.resume = {
                    loadTask.resume()
                }
                configure.cancel = {
                    loadTask.cancel()
                    Task.cancelAll(queuedDownloadTasks)
                    Task.cancelAll(persistTasks)
                }
        }
        return resultTask
    }
}