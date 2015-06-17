//
//  ComicImageDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/25/15.
//
//

import Foundation

protocol ComicImageNetworkDataSource {
    func downloadImageForComic(comic: Comic,
        imageKind: ComicImageKind) -> CancellableAsynchronousTask<Result<NSURL>>?
}