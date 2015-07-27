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
    case LoadingFromPersistence
    case Downloading
    case Loaded(Comic)
    case DownloadFailed
}

protocol ComicModel {
    
    var latestAvailableComic: Comic? { get }
    var isUpdatingLatestAvailableComic: Bool { get }
    func updateLatestAvailableComic() -> Task<Float, Comic, ErrorType>
    
    func addLatestAvailableComicObserverWithHandler(handler: (comic: Comic?) -> ()) -> Any
    func removeLatestAvailableComicObserver(observer: Any)
    
    func addUpdatingLatestAvailableComicObserverWithHandler(handler: (isUpdating: Bool) -> ()) -> Any
    func removeUpdatingLatestAvailableComicObserver(observer: Any)
    
    func updateComicWithNumber(number: Int) -> Task<Float, Comic, ErrorType>
    
    var viewedComicNumbers: Set<Int>? { get set }
    
    func stateOfComicWithNumber(number: Int) -> ComicModelComicState
    subscript (number: Int) -> Comic? { get }
    
    func addComicStateObserverWithHandler(handler: (comicNumbers: Set<Int>) -> ()) -> Any
    func removeComicStateObserver(observer: Any)
}