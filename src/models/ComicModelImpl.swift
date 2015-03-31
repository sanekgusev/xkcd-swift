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
    
    private var _currentMaxComicNumber: Int?
    private var _currentComicNumberRange: Range<Int>?
    
    private lazy var currentMaxComicNumberObserverSet = ObserverSet<Int?>()
    private lazy var comicAvailabilityObserverSet = ObserverSet<Int>()

    private lazy var comixesForComicNumbers = [Int: Comic]()
    
    private lazy var networkOperationsForComicNumbers = NSMapTable.weakToWeakObjectsMapTable()
    private lazy var databaseReadOperationsForComicNumbers = NSMapTable.weakToWeakObjectsMapTable()
    private lazy var databaseWriteOperationsForComicNumbers = NSMapTable.weakToWeakObjectsMapTable()
    
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
}

extension ComicModelImpl: ComicModel {
    
    func updateCurrentMaxComicNumberWithCompletion(completion: (result: VoidResult) -> ()) -> AsyncCancellable {
        var networkOperation: AsynchronousOperation? = nil
        let cancellable = comicNetworkDataSource.retrieveComicOfKind(.MostRecent,
            completion: { result in
                switch result {
                case .Success(let comic) :
                    self.currentMaxComicNumber = comic.number
                    completion(result: .Success)
                case .Failure(let error) :
                    completion(result: .Failure(error))
                }
                
                networkOperation?.completeOperation()
        })
        networkOperation = AsynchronousOperation(spawnBlock: { completion in
            cancellable.start()
        },
            cancellationBlock: { () in
            cancellable.cancel()
        })
        
        networkOperationQueue.addOperation(networkOperation!)
        
        return networkOperation!
    }
    
    private(set) var currentMaxComicNumber: Int? {
        get {
            return _currentMaxComicNumber
        }
        set {
            _currentMaxComicNumber = newValue
            currentMaxComicNumberObserverSet.notify(_currentMaxComicNumber)
        }
    }
    
    func addCurrentMaxComicNumberObserverWithHandler(handler: (comicNumber: Int?) -> ()) -> Any {
        return currentMaxComicNumberObserverSet.add(handler)
    }
    
    func removeCurrentMaxComicNumberObserver(observer: Any) {
        if let observerSetEntry = observer as? ObserverSetEntry<Int?> {
            currentMaxComicNumberObserverSet.remove(observerSetEntry)
        }
    }
    
    func comicWithNumber(number: Int) -> Comic? {
        return comixesForComicNumbers[number]
    }
    
    var currentComicNumberRange: Range<Int>? {
        get { return _currentComicNumberRange }
        set {
            if _currentComicNumberRange != newValue {
                _currentComicNumberRange = newValue
                // TODO: trigger updates
            }
        }
    }
    
    func addComicAvailabilityObserverWithHandler(handler: (comicNumber: Int) -> ()) -> Any {
        return comicAvailabilityObserverSet.add(handler)
    }
    
    func removeComicAvailabilityObserver(observer: Any) {
        if let observerSetEntry = observer as? ObserverSetEntry<Int> {
            comicAvailabilityObserverSet.remove(observerSetEntry)
        }
    }
    
}