//
//  ComicImagePersistentDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation
import QuartzCore

enum ComicImagePersistentDataSourceSize {
    case FullResolution
    case Thumbnail(maxPizelSize: CGFloat)
}

protocol ComicImagePersistentDataSource {
    func loadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        size: ComicImagePersistentDataSourceSize) -> AsynchronousTask<Result<CGImage>>
}