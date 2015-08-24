//
//  ComicImageDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/25/15.
//
//

import Foundation
import SwiftTask

protocol ComicImageNetworkDataSource {
    func downloadImageForComic(comic: Comic,
        imageKind: ComicImageKind) throws -> Task<NormalizedProgressValue, FileURL, ErrorType>
}