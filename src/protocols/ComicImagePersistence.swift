//
//  ComicImagePersistence.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation

protocol ComicImagePersistence {
    func persistComicImageAtURL(URL: NSURL,
        forComic: Comic,
        imageKind: ComicImageKind) -> Result<Void>
}