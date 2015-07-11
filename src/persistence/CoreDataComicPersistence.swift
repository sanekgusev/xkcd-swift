//
//  CoreDataComicPersistence.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/9/15.
//
//

import Foundation
import CoreData

final class CoreDataComicPersistence: ComicPersistence, ComicPersistentDataSource {
    
    /// MARK: Errors
    
    enum Error : ErrorType {
        case FailedToCreateManagedObjectModel
    }
    
    /// MARK: Ivars
    
    private let _storeURL: NSURL
    private let managedObjectModel: NSManagedObjectModel!
    private let writePersistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    private var readManagedObjectContext: NSManagedObjectContext? {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        let readPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let readOptions: [NSObject: AnyObject] = [NSReadOnlyPersistentStoreOption: true,
            NSSQLitePragmasOption: [
                "fullfsync": "0",
                "checkpoint_fullfsync": "0",
                "synchronous": "OFF",
                "read_uncommitted": "1",
                "temp_store": "memory",
                "locking_mode": "EXCLUSIVE",
        ]]
        
        do {
            try readPersistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil,
                URL: _storeURL,
                options: readOptions)
            managedObjectContext.persistentStoreCoordinator = readPersistentStoreCoordinator
            return managedObjectContext
        } catch {
            return nil
        }
    }
    
    private let writeManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)

    /// MARK: Public
    
    init(modelURL: NSURL, storeURL: NSURL) throws {
        _storeURL = storeURL
        guard let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL) else {
            self.managedObjectModel = nil
            self.writePersistentStoreCoordinator = nil
            throw Error.FailedToCreateManagedObjectModel
        }
        
        self.managedObjectModel = managedObjectModel
        self.writePersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        let writeOptions: [NSObject: AnyObject] = [
            NSSQLitePragmasOption: [
                "fullfsync": "0",
                "checkpoint_fullfsync": "1",
                "synchronous": "NORMAL",
                "temp_store": "memory",
                "locking_mode": "EXCLUSIVE",
                "auto-vacuum": "FULL"
            ]]
        try writePersistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                    configuration: nil, URL: storeURL, options: writeOptions)
        writeManagedObjectContext.persistentStoreCoordinator = writePersistentStoreCoordinator
    }
    
    func persistComic(comic: Comic) -> AsynchronousTask<Result<Void>> {
        let asynchronousTask = AsynchronousTask<Result<Void>>(spawnBlock: { (completionBlock) -> () in
            self.writeManagedObjectContext.performBlock {
                guard let _ = CoreDataComic.comicFromComic(comic,
                    insertIntoManagedObjectContext: self.writeManagedObjectContext) else {
                    completionBlock(result: .Failure(nil)) // FIXME: add error
                    return
                }
                do {
                    try self.writeManagedObjectContext.save()
                    self.writeManagedObjectContext.reset()
                    completionBlock(result: .Success())
                } catch let error as NSError {
                    completionBlock(result: .Failure(error))
                } catch {
                    fatalError()
                }
            }
        })
        return asynchronousTask
    }
    
    func loadAllPersistedComicNumbers() -> AsynchronousTask<Result<Set<Int>>> {
        let asynchronousTask = AsynchronousTask<Result<Set<Int>>>(spawnBlock: { (completionBlock) -> () in
            guard let readManagedObjectContext = self.readManagedObjectContext else {
                completionBlock(result: .Failure(nil)) // FIXME: figure out
                return
            }
            readManagedObjectContext.performBlock {
                let fetchRequest = NSFetchRequest(entityName: CoreDataComic.entityName)
                fetchRequest.includesPendingChanges = false
                fetchRequest.shouldRefreshRefetchedObjects = true
                fetchRequest.returnsObjectsAsFaults = false
                fetchRequest.propertiesToFetch = ["number"]
                fetchRequest.resultType = .DictionaryResultType
                do {
                    guard let coreDataComicDictionaries = try readManagedObjectContext.executeFetchRequest(fetchRequest) as? [NSDictionary] else {
                        completionBlock(result: .Failure(nil))
                        return
                    }
                    let comicNumbers = coreDataComicDictionaries.map { coreDataComicDictionary -> Int in
                        if let number = coreDataComicDictionary["number"] as? NSNumber {
                            return number.integerValue
                        }
                        return 0
                    }
                    completionBlock(result: .Success(Set(comicNumbers)))
                }
                catch let error as NSError {
                    completionBlock(result: .Failure(error))
                }
                catch {
                    fatalError()
                }
            }
        })
        return asynchronousTask
    }

    func loadComicsWithNumbers(numbers: Set<Int>) -> AsynchronousTask<Result<KeyedCollection<Int, Comic>>> {
        let asynchronousTask = AsynchronousTask<Result<KeyedCollection<Int, Comic>>>(spawnBlock: { (completionBlock) -> () in
            guard let readManagedObjectContext = self.readManagedObjectContext else {
                completionBlock(result: .Failure(nil)) // TODO: figure out
                return
            }
            readManagedObjectContext.performBlock {
                let fetchRequest = NSFetchRequest(entityName: CoreDataComic.entityName)
                fetchRequest.shouldRefreshRefetchedObjects = true
                fetchRequest.returnsObjectsAsFaults = false
                fetchRequest.predicate = NSPredicate(format: "number IN %@", numbers as NSSet)
                do {
                    guard let coreDataComics = try readManagedObjectContext.executeFetchRequest(fetchRequest) as? [CoreDataComic] else {
                        completionBlock(result: .Failure(nil))
                        return
                    }
                    let comics = coreDataComics.map { $0.comic() }
                    completionBlock(result: .Success(KeyedCollection(comics)))
                }
                catch let error as NSError {
                    completionBlock(result: .Failure(error))
                }
                catch {
                    fatalError()
                }
            }
        })
        return asynchronousTask
    }
}