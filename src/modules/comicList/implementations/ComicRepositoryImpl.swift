//
//  ComicRepositoryImpl.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

import Foundation
import ReactiveCocoa

final class ComicRepositoryImpl: ComicRepository {
    
    private let networkingService: ComicNetworkingService
    private let parsingService: ComicParsingService
    
    init(networkingService: ComicNetworkingService,
         parsingService: ComicParsingService) {
        self.networkingService = networkingService
        self.parsingService = parsingService
    }
    
    func retrieveComic(identifier: ComicIdentifier) -> SignalProducer<Comic, ComicRepositoryError> {
        return networkingService.downloadComic(identifier)
            .mapError({ error -> ComicRepositoryError in
                switch error {
                case .NetworkError:
                    return ComicRepositoryError.NetworkError
                case .ServerError:
                    return ComicRepositoryError.ServerError
                }
            })
            .flatMap(.Merge, transform: { self.parsingService.comicFromData($0).mapError({ _ in ComicRepositoryError.ServerError })
            })
    }
}
