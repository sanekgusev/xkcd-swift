//
//  ComicImagePersistence.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation

protocol ComicImagePersistence {
    func persistComicImageAtURL(URL: FileURL,
        forComic comic: Comic,
        imageKind: ComicImageKind) throws -> FileURL
}