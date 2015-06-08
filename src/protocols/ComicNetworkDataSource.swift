//
//  File.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/20/15.
//
//

import Foundation

protocol ComicNetworkDataSource {
    func downloadComicOfKind(kind: ComicKind) -> CancellableAsynchronousTask<Result<Comic>>
}