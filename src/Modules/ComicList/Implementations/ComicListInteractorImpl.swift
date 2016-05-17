//
//  ComicListInteractorImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import Foundation
import ReactiveCocoa

final class ReactiveComicWrapperImpl: ReactiveComicWrapper {
    
    let comicIdentifier: ComicIdentifier
    private let comicRepository: ComicRepository
    
    private let mutableComic: MutableProperty<Comic?>
    private let mutableLoading = MutableProperty<Bool>(false)
    private let mutableLastLoadError = MutableProperty<ComicRepositoryError?>(nil)
    
    private var retrieveDisposable = SerialDisposable(nil)
    
    var comic: AnyProperty<Comic?> {
        return AnyProperty(mutableComic)
    }
    
    var loading: AnyProperty<Bool> {
        return AnyProperty(mutableLoading)
    }

    var lastLoadError: AnyProperty<ComicRepositoryError?> {
        return AnyProperty(mutableLastLoadError)
    }
    
    private init(comicRepository: ComicRepository, comicIdentifier: ComicIdentifier,
                 comic: Comic? = nil) {
        self.comicRepository = comicRepository
        self.comicIdentifier = comicIdentifier
        self.mutableComic = MutableProperty(comic)
    }
    
    deinit {
        retrieveDisposable.innerDisposable = nil
    }
    
    func retrieveComicWithSignal(@noescape setUp: (Signal<Comic, ComicRepositoryError>, Disposable) -> ()) {
        comicRepository.retrieveComic(comicIdentifier).on(started: {
            self.mutableLoading.value = true
            }, failed: { error in
                self.mutableLastLoadError.value = error
            },terminated: {
                self.mutableLoading.value = false
            }, next: { comic in
                self.mutableComic.value = comic
        }).startWithSignal { signal, disposable in
            retrieveDisposable.innerDisposable = disposable
            setUp(signal, disposable)
        }
    }
}

final class ComicListInteractorImpl: ComicListInteractor {
    
    private static let cacheCountLimit = 100
    
    private let comicRepository: ComicRepository
    private var comicStatesCache: NSCache
    private let latestComicEntry: ReactiveComicWrapper
    
    init(comicRepository: ComicRepository) {
        self.comicRepository = comicRepository
        latestComicEntry = ReactiveComicWrapperImpl(comicRepository: comicRepository,
                                                    comicIdentifier: .Latest)
        comicStatesCache = NSCache()
        comicStatesCache.countLimit = ComicListInteractorImpl.cacheCountLimit
    }
    
    subscript (identifier: ComicIdentifier) -> ReactiveComicWrapper {
        switch identifier {
        case .Latest: return latestComicEntry
        case let .Number(number):
            if let entry = comicStatesCache.objectForKey(number) as! ReactiveComicWrapper? {
                return entry
            }
            let entry = ReactiveComicWrapperImpl(comicRepository: comicRepository,
                                                 comicIdentifier: identifier)
            comicStatesCache.setObject(entry, forKey: number)
            return entry
        }
    }
}

