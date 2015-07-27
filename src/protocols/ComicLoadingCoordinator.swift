//
//  ComicLoadingCoordinator.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/2/15.
//
//

import Foundation
import SwiftTask
import Result

protocol ComicLoadingCoordinator {
    func downloadAndPersistComicOfKind(kind: ComicKind) -> Task<Float, Comic, ErrorType>
    func loadOrDownloadAndPersistComicsWithNumbers(numbers: Set<Int>) -> Task<Result<Comic, ErrorType>, Void, Void>
    func downloadAndPersistNotPersitedComicsWithNumbers(numbers: Set<Int>) -> Task<Result<Int, ErrorType>, Void, Void>
}