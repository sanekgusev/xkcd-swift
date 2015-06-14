//
//  ComicImageLoadingCoordinator.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/2/15.
//
//

import Foundation
import QuartzCore

protocol ComicImageLoadingCoordinator {
    func downloadAndPersistImageForComic(comic: Comic,
        imageKind: ComicImageKind) -> CancellableAsynchronousTask<Result<Void>>
    func loadOrDownloadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        maximumPixelSize: CGSize?) -> CancellableAsynchronousTask<Result<CGImage>>
}