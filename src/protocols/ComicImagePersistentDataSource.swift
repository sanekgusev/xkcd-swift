//
//  ComicImagePersistentDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

import Foundation

protocol ComicImagePersistentDataSource {
    
    func imageFileURLForComicWithNumber(number: Int, imageKind: ComicImageKind) -> NSURL?
    
}