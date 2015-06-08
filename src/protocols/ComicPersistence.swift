//
//  ComicPersistence.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation

protocol ComicPersistence {
    func persistComic(comic: Comic) -> AsynchronousTask<VoidResult>
}