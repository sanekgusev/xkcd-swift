//
//  ComicModel.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation
import SwiftTask

enum ComicModelComicState {
    case NotLoaded
    case Loading
    case Loaded(Comic)
    case LoadFailed(ErrorType)
}

protocol ComicModel {
    
    var latestAvailableComic: Comic? { get }
    var isUpdatingLatestAvailableComic: Bool { get }
    func updateLatestAvailableComic() -> Task<NormalizedProgressValue, Comic, ErrorType>
    
    func addLatestAvailableComicObserverWithHandler(handler: (comic: Comic?) -> ()) -> Any
    func removeLatestAvailableComicObserver(observer: Any)
    
    func addUpdatingLatestAvailableComicObserverWithHandler(handler: (isUpdating: Bool) -> ()) -> Any
    func removeUpdatingLatestAvailableComicObserver(observer: Any)
    
    func updateComicWithNumber(number: ComicNumber) -> Task<NormalizedProgressValue, Comic, ErrorType>
    
    var viewedComicNumbers: Set<ComicNumber>? { get set }
    
    func stateOfComicWithNumber(number: ComicNumber) -> ComicModelComicState
    subscript (number: Int) -> Comic? { get }
    
    func addComicStateObserverWithHandler(handler: (comicNumbers: Set<ComicNumber>) -> ()) -> Any
    func removeComicStateObserver(observer: Any)
}