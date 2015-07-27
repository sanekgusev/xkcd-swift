//
//  ComicPersistence.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation
import SwiftTask

protocol ComicPersistence {
    func persistComic(comic: Comic) -> Task<Void, Void, ErrorType>
}