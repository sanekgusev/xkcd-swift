//
//  ComicModelImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/12/15.
//
//

import Foundation

final class ComicModelImpl {
    
    /// MARK: Constants
    
    private static let maxNumberOfConcurrentNetworkRequests = 5
    private static let maxNumberOfConcurrentDatabaseReads = 5
    private static let maxInMemoryComics = 1000
    private static let maxNumberOfQueuedNetworkRequests = 30
    
    private static var modelURL: NSURL? {
        return NSBundle.mainBundle().URLForResource("xkcd", withExtension: "momd")
    }
    
    private static var storeURL: NSURL? {
        var error: NSError?
        if let applicationSupportDirectoryURL =
            NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.ApplicationSupportDirectory,
                inDomain: NSSearchPathDomainMask.UserDomainMask,
                appropriateForURL: nil,
                create: true,
                error: &error) {
            return applicationSupportDirectoryURL.URLByAppendingPathComponent("xkcd.sqlite")
        }
        println(error);
        return nil
    }
    
    // MARK: Ivars
    
    private lazy var comicNetworkDataSource: ComicNetworkDataSource = ComicDownloader()
    private let comicPersistence: ComicPersistence!
    private let comicPersistentDataSource: ComicPersistentDataSource!
    
    private var _maxComicNumber: Int?
    private var _viewedComicNumberRange: Range<Int>?
    
    private lazy var maxComicNumberObserverSet = ObserverSet<Int?>()
    private lazy var comicStateObserverSet = ObserverSet<[Int]>()

    private lazy var comicsCache = KeyedCollection<Int, Comic>()
    private lazy var comicLoadOperations = NSMapTable.strongToWeakObjectsMapTable()
    private lazy var comicDownloadOperations = NSMapTable.strongToWeakObjectsMapTable()
    
    private lazy var comicDownloadErrors: [Int: NSError?] = [Int: NSError?]()
    
    private lazy var networkOperationQueue: NSOperationQueue = {
        let operationQueue = NSOperationQueue()
        operationQueue.name = "com.sanekgusev.ComicModelImpl.networkQueue"
        operationQueue.maxConcurrentOperationCount = maxNumberOfConcurrentNetworkRequests
        operationQueue.qualityOfService = NSQualityOfService.UserInitiated
        return operationQueue
    }()
    
    private lazy var databaseReadOperationQueue: NSOperationQueue = {
        let operationQueue = NSOperationQueue()
        operationQueue.name = "com.sanekgusev.ComicModelImpl.databaseReadQueue"
        operationQueue.maxConcurrentOperationCount = maxNumberOfConcurrentDatabaseReads
        operationQueue.qualityOfService = NSQualityOfService.UserInitiated
        return operationQueue
    }()
    
    private lazy var databaseWriteOperationQueue: NSOperationQueue = {
        let operationQueue = NSOperationQueue()
        operationQueue.name = "com.sanekgusev.ComicModelImpl.databaseReadQueue"
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.qualityOfService = NSQualityOfService.UserInitiated
        return operationQueue
        }()
    
    // MARK: Init/deinit
    
    init?() {
        if let modelURL = ComicModelImpl.modelURL,
            storeURL = ComicModelImpl.storeURL,
            coreDataComicPersistence = CoreDataComicPersistence(modelURL: modelURL,
            storeURL: storeURL) {
                comicPersistence = coreDataComicPersistence
                comicPersistentDataSource = coreDataComicPersistence
        }
        else {
            comicPersistence = nil
            comicPersistentDataSource = nil
            return nil
        }
    }
    
    // MARK: Private
    
    private func addComicsToMemoryCache(comics: [Comic]) {
        for comic in comics {
            comicsCache.update(comic)
        }
        comicStateObserverSet.notify(map(comics) { comic in comic.number })
    }
    
    private func persistComic(comic: Comic) {
        var operation: AsynchronousOperation?
        let startable = comicPersistence.persistComic(comic,
            completion: { result in
                operation?.completeOperation()
                switch result {
                case .Failure(let error) :
                    print(error)
                default:
                    break
                }
        })
        operation = AsynchronousOperation(spawnBlock: { (completion) -> () in
            startable.start()
        }, cancellationBlock: nil)
        databaseWriteOperationQueue.addOperation(operation!)
    }
    
    private func handleDownloadedComic(comic: Comic) {
        addComicsToMemoryCache([comic])
        persistComic(comic)
    }
    
    private func loadPersistedComicsWithNumbers(numbers: [Int],
        completion: (comics: Set<Comic>) -> ()) {
            var loadOperation: AsynchronousOperation?
            let startable = comicPersistentDataSource.retrieveComicsForNumbers(numbers,
                completion: { (result) -> () in
                    switch result {
                    case .Success(let comics):
                        self.addComicsToMemoryCache(Array(comics))
                        completion(comics: comics)
                    case .Failure(let error):
                        print(error)
                        completion(comics: Set())
                    }
                    loadOperation?.completeOperation()
                })
            loadOperation = AsynchronousOperation(spawnBlock: { (completion) -> () in
                startable.start()
                }, cancellationBlock: nil)
            databaseReadOperationQueue.addOperation(loadOperation!)
    }
    
    private func loadMostRecentPersistentComic(completion: (comic: Comic?) -> ()) {
        var loadOperation: AsynchronousOperation?
        let startable = comicPersistentDataSource.retrieveMostRecentComic { (result) -> () in
            switch result {
                case .Success(let comic):
                    self.addComicsToMemoryCache([comic])
                    completion(comic: comic)
                case .Failure(let error):
                    print(error)
                    completion(comic: nil)
            }
            loadOperation?.completeOperation()
        }
        loadOperation = AsynchronousOperation(spawnBlock: { (completion) -> () in
            startable.start()
        }, cancellationBlock: nil)
        databaseReadOperationQueue.addOperation(loadOperation!)
    }
    
    private func initialLoadMaxComicNumber() {
        loadMostRecentPersistentComic { (comic) -> () in
            if let comic = comic {
                self.maxComicNumber = comic.number
            }
        }
    }
}

extension ComicModelImpl: ComicModel {
    
    func refreshMaxComicNumberWithCompletion(completion: (result: VoidResult) -> ()) -> AsyncCancellable {
        let cancellable = comicNetworkDataSource.retrieveComicOfKind(.MostRecent,
            completion: { result in
                switch result {
                case .Success(let comic) :
                    self.handleDownloadedComic(comic)
                    self.maxComicNumber = comic.number
                    completion(result: .Success)
                case .Failure(let error) :
                    completion(result: .Failure(error))
                }
        })
        return cancellable
    }
    
    private(set) var maxComicNumber: Int? {
        get {
            return _maxComicNumber
        }
        set {
            _maxComicNumber = newValue
            maxComicNumberObserverSet.notify(_maxComicNumber)
        }
    }
    
    func addMaxComicNumberObserverWithHandler(handler: (comicNumber: Int?) -> ()) -> Any {
        return maxComicNumberObserverSet.add(handler)
    }
    
    func removeMaxComicNumberObserver(observer: Any) {
        if let observerSetEntry = observer as? ObserverSetEntry<Int?> {
            maxComicNumberObserverSet.remove(observerSetEntry)
        }
    }
    
    func stateOfComicWithNumber(number: Int) -> ComicModelComicState {
        if let comic = comicsCache[number] {
            return .Loaded(comic)
        }
        if comicDownloadOperations.objectForKey(NSNumber(integer: number)) != nil {
            return .Downloading
        }
        if comicLoadOperations.objectForKey(NSNumber(integer: number)) != nil {
            return .LoadingFromPersistence
        }
        // TODO: return .DownloadFailed too
        return .NotLoaded
    }
    
    var viewedComicNumberRange: Range<Int>? {
        get { return _viewedComicNumberRange }
        set {
            if _viewedComicNumberRange != newValue {
                _viewedComicNumberRange = newValue
                // TODO: trigger updates
            }
        }
    }
    
    func addComicStateObserverWithHandler(handler: (comicNumbers: [Int]) -> ()) -> Any {
        return comicStateObserverSet.add(handler)
    }
    
    func removeComicStateObserver(observer: Any) {
        if let observerSetEntry = observer as? ObserverSetEntry<[Int]> {
            comicStateObserverSet.remove(observerSetEntry)
        }
    }
    
    func redownloadComicWithNumber(number: Int, completion: (result: ComicResult) -> ()) -> AsyncCancellable {
        return NSOperation()
    }
    
}