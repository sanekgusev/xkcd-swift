//
//  ComicModel.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation
import ReactiveCocoa

struct ComicModelComicState {
    enum ComicState {
        case Invalid, NotLoaded, Loaded(Comic)
    }
    enum LoadingState {
        case Idle, Loading, LastLoadFailed(ComicModelError)
    }
    
    var comicState: ComicState
    var loadingState: LoadingState
}

enum ComicModelError: ErrorType {
    case ComicLoadFailed(underlyingError: ErrorType)
}

protocol ComicModel {
    
    func updateComicWithIdentifier(identifier: ComicIdentifier) -> SignalProducer<Comic, ComicModelError>
    
    var viewedComicNumbers: MutableProperty<Set<Comic.Number>> { get }
    
    subscript (identifier: ComicIdentifier) -> AnyProperty<ComicModelComicState> { get }
}