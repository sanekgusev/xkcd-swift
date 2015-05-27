//
//  ComicModel.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation

enum ComicModelComicState {
    case NotLoaded
    case LoadingFromPersistence
    case Downloading
    case Loaded(Comic)
    case DownloadFailed(NSError?)
}

protocol ComicModel {
    
    var maxComicNumber: Int? { get }
    func refreshMaxComicNumberWithCompletion(completion: (result: VoidResult) -> ()) -> AsyncCancellable
    
    func addMaxComicNumberObserverWithHandler(handler: (comicNumber: Int?) -> ()) -> Any
    func removeMaxComicNumberObserver(observer: Any)
    
    func stateOfComicWithNumber(number: Int) -> ComicModelComicState
    var viewedComicNumberRange: Range<Int>? { get set }
    
    func redownloadComicWithNumber(number: Int, completion: (result: ComicResult) -> ()) -> AsyncCancellable
    
    func addComicStateObserverWithHandler(handler: (comicNumbers: [Int]) -> ()) -> Any
    func removeComicStateObserver(observer: Any)
}