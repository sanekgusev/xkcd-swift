//
//  ComicListInteractorImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import Foundation
import ReactiveCocoa

final class ComicListInteractorImpl: ComicListInteractor {
    
    private static let cacheCountLimit = 100
    
    private let comicRepository: ComicRepository
    private var comicStatesCache: NSCache
    private let latestComicEntry: ReactiveComic
    
    init(comicRepository: ComicRepository) {
        self.comicRepository = comicRepository
        latestComicEntry = ReactiveComic(ReactiveEntityFetcherAdapter(repository: comicRepository,
            identifier: ComicIdentifier.Latest))
        comicStatesCache = NSCache()
        comicStatesCache.countLimit = self.dynamicType.cacheCountLimit
    }
    
    subscript (identifier: ComicIdentifier) -> ReactiveComic {
        switch identifier {
        case .Latest: return latestComicEntry
        case let .Number(number):
            if let entry = comicStatesCache.objectForKey(number) as! ReactiveComic? {
                return entry
            }
            let entry = ReactiveComic(ReactiveEntityFetcherAdapter(repository: comicRepository,
                identifier: identifier))
            comicStatesCache.setObject(entry, forKey: number)
            return entry
        }
    }
}

