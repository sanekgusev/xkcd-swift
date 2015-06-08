//
//  ComicResult.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/31/15.
//
//

import Foundation

enum ComicResult {
    case Success(Comic)
    case Failure(NSError?)
}

enum ComicCollectionResult {
    case Success(KeyedCollection<Int, Comic>)
    case Failure(NSError?)
}

enum ComicNumbersResult {
    case Success(Set<Int>)
    case Failure(NSError?)
}