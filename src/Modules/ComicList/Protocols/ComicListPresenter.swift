//
//  ComicListPresenter.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import ReactiveCocoa

protocol ComicListPresenter: ComicListLoadingPresenter {
    
    var comicCount: AnyProperty<UInt?> { get }
    
    subscript (index: UInt) -> ReactiveComicWrapper { get }
    func selectComicAtIndex(index: UInt)
    
    // TODO: manage selected state
}
