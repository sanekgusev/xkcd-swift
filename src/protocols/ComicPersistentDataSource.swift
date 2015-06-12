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
    func loadComicsWithNumbers(numbers: Set<Int>) -> AsynchronousTask<Result<KeyedCollection<Int, Comic>>>
}