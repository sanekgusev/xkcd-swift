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
    func loadComicsWithNumbers(numbers: Set<Int>) -> Task<Void, KeyedCollection<Int, Comic>, ErrorType>
    func fetchPersistedComicNumbers(numbers: Set<Int>) -> Task<Void, Set<Int>, ErrorType>
}