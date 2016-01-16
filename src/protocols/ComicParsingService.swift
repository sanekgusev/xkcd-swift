//
//  ComicParserService.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 1/14/16.
//
//

import Foundation
import ReactiveCocoa

enum ComicParsingServiceError : ErrorType {
    case MalformedEncodingError(underlyingError: ErrorType?)
    case MalformedPayloadError(underlyingError: ErrorType?)
}

protocol ComicParsingService {
    func comicFromData(data: NSData) -> SignalProducer<Comic, ComicParsingServiceError>
}
