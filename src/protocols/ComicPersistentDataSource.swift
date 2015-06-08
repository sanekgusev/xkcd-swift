//
//  ComicPersistentDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation

protocol ComicPersistentDataSource {
    func loadAllPersistedComicNumbers() -> AsynchronousTask<ComicNumbersResult>
    
    func loadComicWithNumber(number: Int) -> AsynchronousTask<Result<Comic>>
    func loadComicsWithNumbers(numbers: Set<Int>) -> AsynchronousTask<ComicCollectionResult>
    func loadMostRecentComic() -> AsynchronousTask<Result<Comic>>
}