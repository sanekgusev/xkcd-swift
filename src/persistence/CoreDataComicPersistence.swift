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
    
    /// MARK: Ivars
    
    private let _storeURL: NSURL
    private let managedObjectModel: NSManagedObjectModel!
    private let writePersistentStoreCoordinator: NSPersistentStoreCoordinator!
    
    private var readManagedObjectContext: NSManagedObjectContext? {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
        let readPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        var error: NSError?
        
        let readOptions: [NSObject: AnyObject] = [NSReadOnlyPersistentStoreOption: true,
            NSSQLitePragmasOption: [
                "fullfsync": "0",
                "checkpoint_fullfsync": "0",
                "synchronous": "OFF",
                "read_uncommitted": "1",
                "temp_store": "memory",
                "locking_mode": "EXCLUSIVE",
        ]]
        
        if let persistentStore = readPersistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
            configuration: nil,
            URL: _storeURL,
            options: readOptions,
            error: &error) {
            managedObjectContext.persistentStoreCoordinator = readPersistentStoreCoordinator
            return managedObjectContext
        }
        return nil
    }
    
    private let writeManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)

    /// MARK: Public
    
    init?(modelURL: NSURL, storeURL: NSURL) {
        _storeURL = storeURL
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)
        if let managedObjectModel = managedObjectModel {
            self.managedObjectModel = managedObjectModel
            self.writePersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            
            var error: NSError?
            
            let writeOptions: [NSObject: AnyObject] = [
                NSSQLitePragmasOption: [
                    "fullfsync": "0",
                    "checkpoint_fullfsync": "1",
                    "synchronous": "NORMAL",
                    "temp_store": "memory",
                    "locking_mode": "EXCLUSIVE",
                    "auto-vacuum": "FULL"
            ]]
            if writePersistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                configuration: nil, URL: storeURL, options: writeOptions, error: &error) == nil {
                    println(error)
                    return nil
            }
            writeManagedObjectContext.persistentStoreCoordinator = writePersistentStoreCoordinator
        }
        else {
            self.managedObjectModel = nil
            self.writePersistentStoreCoordinator = nil
            return nil
        }
    }
    
    func persistComic(comic: Comic) -> AsynchronousTask<Result<Void>> {
        let asynchronousTask = AsynchronousTask<Result<Void>>(spawnBlock: { (completionBlock) -> () in
            self.writeManagedObjectContext.performBlock {
                if let coreDataComic = CoreDataComic.comicFromComic(comic,
                    insertIntoManagedObjectContext: self.writeManagedObjectContext) {
                        var error: NSError?
                        if self.writeManagedObjectContext.save(&error) {
                            self.writeManagedObjectContext.reset()
                            completionBlock(result: .Success())
                        }
                        else {
                            completionBlock(result: .Failure(error))
                        }
                }
                else {
                    completionBlock(result: .Failure(nil)) // FIXME: add error
                }
            }
        })
        return asynchronousTask
    }
    
    func loadAllPersistedComicNumbers() -> AsynchronousTask<Result<Set<Int>>> {
        let asynchronousTask = AsynchronousTask<Result<Set<Int>>>(spawnBlock: { (completionBlock) -> () in
            if let readManagedObjectContext = self.readManagedObjectContext {
                readManagedObjectContext.performBlock {
                    var error: NSError?
                    let fetchRequest = NSFetchRequest(entityName: CoreDataComic.entityName)
                    fetchRequest.includesPendingChanges = false
                    fetchRequest.shouldRefreshRefetchedObjects = true
                    fetchRequest.returnsObjectsAsFaults = false
                    fetchRequest.propertiesToFetch = ["number"]
                    fetchRequest.resultType = .DictionaryResultType
                    let coreDataComicDictionaries = readManagedObjectContext.executeFetchRequest(fetchRequest,
                        error: &error) as? [NSDictionary]
                    if let coreDataComicDictionaries = coreDataComicDictionaries {
                        let comicNumbers = coreDataComicDictionaries.map { coreDataComicDictionary -> Int in
                            if let number = coreDataComicDictionary["number"] as? NSNumber {
                                return number.integerValue
                            }
                            return 0
                        }
                        completionBlock(result: .Success(Set(comicNumbers)))
                    }
                    else {
                        completionBlock(result: .Failure(error))
                    }
                }
            }
            else {
                // FIXME: figure out
            }
        })
        return asynchronousTask
    }

    func loadComicsWithNumbers(numbers: Set<Int>) -> AsynchronousTask<Result<KeyedCollection<Int, Comic>>> {
        let asynchronousTask = AsynchronousTask<Result<KeyedCollection<Int, Comic>>>(spawnBlock: { (completionBlock) -> () in
            if let readManagedObjectContext = self.readManagedObjectContext {
                readManagedObjectContext.performBlock {
                    var error: NSError?
                    let fetchRequest = NSFetchRequest(entityName: CoreDataComic.entityName)
                    fetchRequest.shouldRefreshRefetchedObjects = true
                    fetchRequest.returnsObjectsAsFaults = false
                    fetchRequest.predicate = NSPredicate(format: "number IN %@", numbers as NSSet)
                    let coreDataComics = readManagedObjectContext.executeFetchRequest(fetchRequest,
                        error: &error) as? [CoreDataComic]
                    if let coreDataComics = coreDataComics {
                        let comics = coreDataComics.map { coreDataComic in
                            return coreDataComic.comic()
                        }
                        completionBlock(result: .Success(KeyedCollection(comics)))
                    }
                    else {
                        completionBlock(result: .Failure(error))
                    }
                }
            }
            else {
                // FIXME: figure out
            }
        })
        return asynchronousTask
    }
}