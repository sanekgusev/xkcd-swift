//
//  ComicInteractor.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation
import ReactiveCocoa

struct ComicInteractorError: ErrorType {
    let underlyingError: ErrorType
}

protocol ComicInteractorComicState {
    var comic: AnyProperty<Comic?> { get }
    var loading: AnyProperty<Bool> { get }
    var lastLoadError: AnyProperty<ComicInteractorError?> { get }
    
    func retrieveComic()
    func cancelRetrieve()
}

protocol ComicInteractor {
    subscript (identifier: ComicIdentifier) -> ComicInteractorComicState { get }
}