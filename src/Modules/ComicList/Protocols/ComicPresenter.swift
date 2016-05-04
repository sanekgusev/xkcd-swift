//
//  ComicPresenter.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import ReactiveCocoa

protocol ComicPresenter {
    
    var comicCount: AnyProperty<UInt?> { get }
    var refreshing: AnyProperty<Bool> { get }
    var lastRefreshError: AnyProperty<ComicRepositoryError?> { get }
    
    subscript (index: UInt) -> ReactiveComicWrapper { get }
    func selectComicAtIndex(index: UInt)
}
