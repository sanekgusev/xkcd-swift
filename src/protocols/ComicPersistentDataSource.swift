//
//  ComicPersistentDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation

protocol ComicPersistentDataSource {
    
    func retrieveComixesForNumbers(numbers: Set<Int>,
        completion:(result: ComicCollectionResult) -> ()) -> AsyncStartable
    
    func retrieveMostRecentComic(#completion:(result: ComicResult) -> ()) -> AsyncStartable
    
}