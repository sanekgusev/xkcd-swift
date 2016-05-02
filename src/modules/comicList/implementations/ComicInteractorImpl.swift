//
//  ComicInteractorImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import Foundation
import ReactiveCocoa

final class ComicInteractorComicStateImpl: ComicInteractorComicState {
    
    let comicIdentifier: ComicIdentifier
    private let comicRepository: ComicRepository
    
    private let mutableComic: MutableProperty<Comic?>
    private let mutableLoading = MutableProperty<Bool>(false)
    private let mutableLastLoadError = MutableProperty<ComicInteractorError?>(nil)
    
    private var retrieveDisposable = SerialDisposable(nil)
    
    var comic: AnyProperty<Comic?> {
        return AnyProperty(mutableComic)
    }
    
    var loading: AnyProperty<Bool> {
        return AnyProperty(mutableLoading)
    }
    
    var lastLoadError: AnyProperty<ComicInteractorError?> {
        return AnyProperty(mutableLastLoadError)
    }
    
    private init(comicRepository: ComicRepository, comicIdentifier: ComicIdentifier,
                 comic: Comic? = nil) {
        self.comicRepository = comicRepository
        self.comicIdentifier = comicIdentifier
        self.mutableComic = MutableProperty(comic)
    }
    
    deinit {
        cancelRetrieve()
    }
    
    func retrieveComic() {
        retrieveDisposable.innerDisposable = comicRepository.retrieveComic(comicIdentifier).on(started: {
            self.mutableLoading.value = true
            }, event: { event in
                //
            }, failed: { error in
                self.mutableLastLoadError.value = ComicInteractorError(underlyingError: error)
            }, completed: { 
                //
            }, interrupted: { 
                //
            }, terminated: { 
                self.mutableLoading.value = false
            }, disposed: { 
                //
            }, next: { comic in
                self.mutableComic.value = comic
            }).start()
    }
    
    func cancelRetrieve() {
        retrieveDisposable.innerDisposable = nil
    }
}

final class ComicInteractorImpl: ComicInteractor {
    
    private static let cacheCountLimit = 100
    
    private let comicRepository: ComicRepository
    private var comicStatesCache: NSCache
    private let latestComicEntry: ComicInteractorComicState
    
    init(comicRepository: ComicRepository) {
        self.comicRepository = comicRepository
        latestComicEntry = ComicInteractorComicStateImpl(comicRepository: comicRepository,
                                                         comicIdentifier: .Latest)
        comicStatesCache = NSCache()
        comicStatesCache.countLimit = ComicInteractorImpl.cacheCountLimit
    }
    
    subscript (identifier: ComicIdentifier) -> ComicInteractorComicState {
        switch identifier {
        case .Latest: return latestComicEntry
        case let .Number(number):
            if let entry = comicStatesCache.objectForKey(number) as! ComicInteractorComicState? {
                return entry
            }
            let entry = ComicInteractorComicStateImpl(comicRepository: comicRepository,
                                                      comicIdentifier: identifier)
            comicStatesCache.setObject(entry, forKey: number)
            return entry
        }
    }
}

