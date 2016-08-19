//
//  ComicListPresenterImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import ReactiveCocoa

final class ComicListPresenterImpl: ComicListPresenter {
    
    let interactor: ComicListInteractor
    let router: ComicListRouter
    
    lazy var mutableComicCount: MutableProperty<UInt?> = {
        let reactiveLatestComic = self.interactor[.Latest].comic
        let mutableComicCount = MutableProperty(reactiveLatestComic.value?.number)
        
        let mappedProducer = reactiveLatestComic.producer.map({ $0?.number })
        
        mutableComicCount <~ mappedProducer
        
        return mutableComicCount
    }()
    
    init(interactor: ComicListInteractor,
         router: ComicListRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    var comicCount: AnyProperty<UInt?> {
        return AnyProperty(mutableComicCount)
    }
    var refreshing: AnyProperty<Bool> {
        return AnyProperty(interactor[.Latest].loading)
    }
    var lastRefreshError: AnyProperty<ComicRepositoryError?> {
        return AnyProperty(interactor[.Latest].lastLoadError)
    }
    
    subscript (index: UInt) -> ReactiveComicType? {
        guard let latestComicNumber = interactor[.Latest].comic.value?.number else {
            return nil
        }
        return interactor[.Number(latestComicNumber - index)]
    }
    
    func selectComicAtIndex(index: UInt) {
        let reactiveComic = interactor[.Number(index + 1)]
        router.handleComicSelected(reactiveComic)
    }
    
    func refreshComicCountWithSignal(@noescape setUp: (Signal<UInt, ComicRepositoryError>, Disposable) -> ()) {
        interactor[.Latest].retrieveComicWithSignal({ signal, disposable in
            setUp(signal.map({ $0.number }), disposable)
        })
    }
}
