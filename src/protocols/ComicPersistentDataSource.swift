//
//  ComicPersistentDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation
import SwiftTask

protocol ComicPersistentDataSource {
    func loadAllPersistedComics() -> Task<Void, KeyedCollection<ComicNumber, Comic>, ErrorType>
    func loadComicsWithNumbers(numbers: Set<Int>) -> Task<Void, KeyedCollection<ComicNumber, Comic>, ErrorType>
    func fetchPersistedComicNumbers(numbers: Set<Int>) -> Task<Void, Set<ComicNumber>, ErrorType>
}