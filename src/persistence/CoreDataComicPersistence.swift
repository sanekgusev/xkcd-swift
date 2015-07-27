//
//  CoreDataComicPersistence.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/9/15.
//
//

import Foundation
import CoreData
import SwiftTask

final class CoreDataComicPersistence: ComicPersistence, ComicPersistentDataSource {
    
    /// MARK: Errors
    
    enum Error : ErrorType {
        case FailedToCreateManagedObjectModel
        case FailedToCreateReadManagedObjectContext
        case FailedToGetEntityDescription
        case FailedToGetPropertyDescription
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
    
    func persistComic(comic: Comic) -> Task<Void, Void, ErrorType> {
        return Task<Void, Void, ErrorType>(weakified: false,
            paused: true) { (progress, fulfill, reject, configure) -> Void in
                configure.resume = {
                    self.writeManagedObjectContext.performBlock({ () -> Void in
                        do {
                            try self.writeManagedObjectContext.save()
                            self.writeManagedObjectContext.reset()
                            fulfill()
                        } catch let error as NSError {
                            reject(error)
                        } catch {
                            fatalError()
                        }
                    })
                }
        }
    }

    func loadComicsWithNumbers(numbers: Set<Int>) -> Task<Void, KeyedCollection<Int, Comic>, ErrorType> {
        return Task<Void, KeyedCollection<Int, Comic>, ErrorType>(weakified: false,
            paused: true) { (progress, fulfill, reject, configure) -> Void in
                configure.resume = {
                    guard let readManagedObjectContext = self.readManagedObjectContext else {
                        reject(Error.FailedToCreateReadManagedObjectContext)
                        return
                    }
                    readManagedObjectContext.performBlock {
                        let fetchRequest = NSFetchRequest(entityName: CoreDataComic.entityName)
                        fetchRequest.shouldRefreshRefetchedObjects = true
                        fetchRequest.returnsObjectsAsFaults = false
                        fetchRequest.predicate = NSPredicate(format: "number IN %@", numbers as NSSet)
                        do {
                            let coreDataComics = try readManagedObjectContext.executeFetchRequest(fetchRequest) as! [CoreDataComic]
                            let comics = coreDataComics.map { $0.comic() }
                            fulfill(KeyedCollection(comics))
                        }
                        catch let error as NSError {
                            reject(error)
                        }
                        catch {
                            fatalError()
                        }
                    }
                }
        }
    }
    
    func fetchPersistedComicNumbers(numbers: Set<Int>) -> Task<Void, Set<Int>, ErrorType> {
        return Task<Void, Set<Int>, ErrorType>(weakified: false,
            paused: true,
            initClosure: { (progress, fulfill, reject, configure) -> Void in
                guard let readManagedObjectContext = self.readManagedObjectContext else {
                    reject(Error.FailedToCreateReadManagedObjectContext)
                    return
                }
                readManagedObjectContext.performBlock {
                    let fetchRequest = NSFetchRequest(entityName: CoreDataComic.entityName)
                    fetchRequest.returnsObjectsAsFaults = true
                    fetchRequest.includesPendingChanges = false
                    fetchRequest.resultType = .DictionaryResultType
                    guard let entityDescription = NSEntityDescription.entityForName(CoreDataComic.entityName,
                        inManagedObjectContext: readManagedObjectContext) else {
                            reject(Error.FailedToGetEntityDescription)
                            return
                    }
                    guard let numberPropertyDescription = entityDescription.propertiesByName["number"] else {
                        reject(Error.FailedToGetPropertyDescription)
                        return
                    }
                    fetchRequest.propertiesToFetch = [numberPropertyDescription]
                    fetchRequest.predicate = NSPredicate(format: "number IN %@", numbers as NSSet)
                    do {
                        let coreDataComics = try readManagedObjectContext.executeFetchRequest(fetchRequest) as! [NSDictionary]
                        let comicNumbers = coreDataComics.map { $0["number"] as! Int }
                        fulfill(Set(comicNumbers))
                    }
                    catch let error as NSError {
                        reject(error)
                    }
                    catch {
                        fatalError()
                    }
                }
        })
    }
}