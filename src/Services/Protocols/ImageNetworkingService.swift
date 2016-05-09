//
//  ComicImageDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/25/15.
//
//

import ReactiveCocoa
import Foundation

enum ImageNetworkingServiceError: ErrorType {
    case NetworkError(underlyingError: ErrorType?), ServerError(underlyingError: ErrorType?)
}

protocol ImageNetworkingService {
    func downloadImageForURL(imageURL: NSURL) -> SignalProducer<FileURL, ImageNetworkingServiceError>
}