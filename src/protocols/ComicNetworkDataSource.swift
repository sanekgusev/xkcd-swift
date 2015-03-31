//
//  File.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/20/15.
//
//

import Foundation

enum ComicNetworkDataSourceComicKind {
    case ByNumber(Int)
    case MostRecent
}

protocol ComicNetworkDataSource {
    
    func retrieveComicOfKind(kind: ComicNetworkDataSourceComicKind,
        completion: (result: ComicResult) -> ()) -> AsyncCancellable
    
}