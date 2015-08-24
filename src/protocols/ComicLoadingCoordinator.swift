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
    func downloadAndPersistComicOfKind(kind: ComicKind) -> Task<NormalizedProgressValue, Comic, ErrorType>
    
    func loadOrDownloadAndPersistComicsWithNumbers(numbers: Set<ComicNumber>) -> Task<Result<Comic, NSError>, Void, Void>
    func downloadAndPersistNotPersitedComicsWithNumbers(numbers: Set<ComicNumber>) -> Task<Result<ComicNumber, NSError>, Void, Void>
}