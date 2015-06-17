//
//  ComicLoadingCoordinator.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/2/15.
//
//

import Foundation

protocol ComicLoadingCoordinator {
    func downloadAndPersistComicOfKind(kind: ComicKind,
        qualityOfService: NSQualityOfService) -> CancellableAsynchronousTask<Result<Comic>>
}