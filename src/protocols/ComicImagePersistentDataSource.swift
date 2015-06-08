//
//  ComicImagePersistentDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation
import QuartzCore

protocol ComicImagePersistentDataSource {
    func loadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        maximumPixelSize: CGSize?) -> AsynchronousTask<Result<CGImage>>
}