//
//  File.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/20/15.
//
//

import ReactiveCocoa
import Foundation

enum ComicNetworkingServiceError: ErrorType {
    case NetworkError(underlyingError: ErrorType?), ServerError(underlyingError: ErrorType?)
}

protocol ComicNetworkingService {
    func downloadComic(identifier: ComicIdentifier) -> SignalProducer<NSData, ComicNetworkingServiceError>
}