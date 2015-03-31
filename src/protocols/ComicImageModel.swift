//
//  ComicImageModel.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation
import CoreGraphics

protocol ComicImageModel {
    func imageForComic(comic: Comic) -> CGImage?
    var currentComicNumberRange: Range<Int> { get set }
    
    func addObserverWithHandler(handler: (comicNumber: Int) -> ()) -> Any
    func removeObserver(observer: Any)
}