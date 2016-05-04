//
//  ComicPresenterImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import ReactiveCocoa

final class ComicPresenterImpl: ComicPresenter {
    
    let interactor: ComicInteractor
    let router: ComicListRouter
    
    init(interactor: ComicInteractor,
         router: ComicListRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    var comicCount: AnyProperty<UInt?> {
        let reactiveLatestComic = interactor[.Latest].comic
        return AnyProperty(initialValue: reactiveLatestComic.value?.number,
                           producer: reactiveLatestComic.producer.map({ $0?.number }))
    }
    var refreshing: AnyProperty<Bool> {
        return interactor[.Latest].loading
    }
    var lastRefreshError: AnyProperty<ComicRepositoryError?> {
        return interactor[.Latest].lastLoadError
    }
    
    subscript (index: UInt) -> ReactiveComicWrapper {
        return interactor[.Number(index + 1)]
    }
    
    func selectComicAtIndex(index: UInt) {
        let reactiveComic = interactor[.Number(index + 1)]
        self.router.handleComicSelected(reactiveComic)
    }
    
}
