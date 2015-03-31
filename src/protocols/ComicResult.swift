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
    case Success(Set<Comic>)
    case Failure(NSError?)
}