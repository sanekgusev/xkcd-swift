//
//  ComicPersistentDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation

protocol ComicPersistentDataSource {
    func loadAllPersistedComicNumbers() -> AsynchronousTask<Result<Set<Int>>>
    
    func loadComicWithNumber(number: Int) -> AsynchronousTask<Result<Comic>>
    func loadComicsWithNumbers(numbers: Set<Int>) -> AsynchronousTask<KeyedCollection<Int, Comic>>
    func loadMostRecentComic() -> AsynchronousTask<Result<Comic>>
}