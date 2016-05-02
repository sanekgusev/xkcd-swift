//
//  ComicRepository.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 1/17/16.
//
//

import ReactiveCocoa
import Result

enum ComicRepositoryError: ErrorType {
    case NetworkError, ServerError
}

protocol ComicRepository {
    func retrieveComic(identifier: ComicIdentifier) -> SignalProducer<Comic, ComicRepositoryError>
}

extension ComicRepository {
    func retrieveComics<S: SequenceType where S.Generator.Element == Comic.Number> (numbers: S) -> SignalProducer<(number: Comic.Number, result: Result<Comic, ComicRepositoryError>), ReactiveCocoa.NoError> {
        return SignalProducer(values: numbers).flatMap(.Merge, transform: { number in
            return self.retrieveComic(.Number(number))
                .takeLast(1)
                .map { Result(value: $0) }
                .flatMapError { SignalProducer(value: Result(error: $0)) }
                .map { (number: number, result: $0) }
        })
    }
}
