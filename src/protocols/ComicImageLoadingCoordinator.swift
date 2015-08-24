//
//  ComicImageLoadingCoordinator.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/2/15.
//
//

import Foundation
import QuartzCore
import SwiftTask

enum ComicImageLoadingCoordinatorMode {
    case FullResolution
    case Thumbnail(maxPixelSize: CGFloat)
}

protocol ComicImageLoadingCoordinator {
    func downloadAndPersistIfMissingImageForComic(comic: Comic,
        imageKind: ComicImageKind) -> Task<NormalizedProgressValue, Void, ErrorType>
    func downloadPersistAndLoadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        mode: ComicImageLoadingCoordinatorMode) -> Task<NormalizedProgressValue, CGImage, ErrorType>
    func loadStoredOrDownloadPersistAndLoadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        mode: ComicImageLoadingCoordinatorMode) -> Task<NormalizedProgressValue, CGImage, ErrorType>
}