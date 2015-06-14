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
        let writeOperation = NSBlockOperation {
            self.writeManagedObjectContext.performBlock {
                if let coreDataComic = CoreDataComic.comicFromComic(comic,
                    insertIntoManagedObjectContext: self.writeManagedObjectContext) {
                        var error: NSError?
                        if self.writeManagedObjectContext.save(&error) {
                            self.writeManagedObjectContext.reset()
                            completion(result: .Success)
                        }
                        else {
                            completion(result: .Failure(error))
                        }
                }
                else {
                    completion(result: .Failure(nil)) // FIXME
                }
            }
        }
        return writeOperation
    }
    
    func loadAllPersistedComicNumbers() -> AsynchronousTask<Result<Set<Int>>> {
        
    }

    func loadComicsWithNumbers(numbers: Set<Int>) -> AsynchronousTask<Result<KeyedCollection<Int, Comic>>> {
            let readOperation = NSBlockOperation {
                let readManagedObjectContext = self.readManagedObjectContext
                readManagedObjectContext.performBlock {
                    var error: NSError?
                    let fetchRequest = NSFetchRequest(entityName: CoreDataComic.entityName)
                    fetchRequest.includesPendingChanges = false
                    fetchRequest.shouldRefreshRefetchedObjects = true
                    fetchRequest.returnsObjectsAsFaults = false
                    fetchRequest.predicate = NSPredicate(format: "number IN %@", numbers as NSArray)
                    let coreDataComics = readManagedObjectContext.executeFetchRequest(fetchRequest,
                        error: &error) as? [CoreDataComic]
                    if let coreDataComics = coreDataComics {
                        let comics = coreDataComics.map { coreDataComic in
                                return coreDataComic.comic()
                            }
                        completion(result: .Success(Set(comics)))
                    }
                    else {
                        completion(result: .Failure(error))
                    }
                }
            }
            return readOperation
    }
    
//    func retrieveMostRecentComic(#completion:(result: ComicResult) -> ()) -> AsyncStartable {
//        let readOperation = NSBlockOperation {
//            let readManagedObjectContext = self.readManagedObjectContext
//            readManagedObjectContext.performBlock {
//                var error: NSError?
//                let fetchRequest = NSFetchRequest(entityName: CoreDataComic.entityName)
//                fetchRequest.includesPendingChanges = false
//                fetchRequest.shouldRefreshRefetchedObjects = true
//                fetchRequest.returnsObjectsAsFaults = false
//                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "number", ascending:false)]
//                fetchRequest.fetchLimit = 1
//                let coreDataComics = readManagedObjectContext.executeFetchRequest(fetchRequest,
//                    error: &error) as? [CoreDataComic]
//                if let coreDataComics = coreDataComics {
//                    if let firstComic = coreDataComics.first?.comic() {
//                        completion(result: .Success(firstComic))
//                    }
//                    else {
//                        completion(result: .Failure(nil)) // FIXME
//                    }
//                }
//                else {
//                    completion(result: .Failure(error))
//                }
//            }
//        }
//        return readOperation
//    }
}