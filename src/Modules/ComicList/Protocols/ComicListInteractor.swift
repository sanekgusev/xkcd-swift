//
//  ComicListInteractor.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

protocol ComicListInteractor {
    subscript (identifier: ComicIdentifier) -> ReactiveComic { get }
}