//
//  ComicListLoadingPresenter.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 09/05/16.
//
//

import ReactiveCocoa

protocol ComicListLoadingPresenter {
    
    var refreshing: AnyProperty<Bool> { get }
    var lastRefreshError: AnyProperty<ComicRepositoryError?> { get }
    
    func refreshComicCountWithSignal(@noescape setUp: (Signal<UInt, ComicRepositoryError>, Disposable) -> ())
}
