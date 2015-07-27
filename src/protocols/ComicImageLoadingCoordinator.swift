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

protocol ComicImageLoadingCoordinator {
    func downloadAndPersistImageForComic(comic: Comic,
        imageKind: ComicImageKind) -> Task<Float, Void, ErrorType>
    func loadOrDownloadImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        maximumPixelSize: CGSize?) -> Task<Float, CGImage, ErrorType>
}