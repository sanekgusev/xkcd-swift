//
//  ComicImageDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/25/15.
//
//

import ReactiveCocoa
import Foundation

enum ComicImageNetworkingServiceError: ErrorType {
    case NetworkError(underlyingError: ErrorType?), ServerError(underlyingError: ErrorType?)
    case MissingImageURLError
}

protocol ComicImageNetworkingService {
    func downloadImageForComic(comic: Comic,
        imageKind: ComicImageKind) -> SignalProducer<FileURL, ComicImageNetworkingServiceError>
}