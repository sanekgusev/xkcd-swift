//
//  ComicImagePersistentDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation
import SwiftTask

protocol ComicImagePersistentDataSource {
    func getImageFileURLForComic(comic: Comic,
            imageKind: ComicImageKind,
            qualityOfService: NSQualityOfService) -> Task<Void, FileURL, ErrorType>
}