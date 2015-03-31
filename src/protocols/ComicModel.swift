//
//  ComicModel.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation

protocol ComicModel {
    
    var currentMaxComicNumber: Int? { get }
    func updateCurrentMaxComicNumberWithCompletion(completion: (result: VoidResult) -> ()) -> AsyncCancellable
    
    func addCurrentMaxComicNumberObserverWithHandler(handler: (comicNumber: Int?) -> ()) -> Any
    func removeCurrentMaxComicNumberObserver(observer: Any)
    
    func comicWithNumber(number: Int) -> Comic?
    var currentComicNumberRange: Range<Int>? { get set }
    
    func addComicAvailabilityObserverWithHandler(handler: (comicNumber: Int) -> ()) -> Any
    func removeComicAvailabilityObserver(observer: Any)
}