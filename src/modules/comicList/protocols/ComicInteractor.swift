//
//  ComicInteractor.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/6/15.
//
//

protocol ComicInteractor {
    subscript (identifier: ComicIdentifier) -> ReactiveComicWrapper { get }
}