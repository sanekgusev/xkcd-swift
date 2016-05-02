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
        return AnyProperty(initialValue: interactor[.Latest].comic.value?.number,
                           producer: interactor[.Latest].comic.producer.map({ $0?.number }))
    }
    var refreshing: AnyProperty<Bool> { get }
    var lastRefreshError: AnyProperty<ComicInteractorError?> { get }
    
    subscript (index: UInt) -> ComicInteractorComicState { get }
    func selectComicAtIndex(index: UInt)
    
}
