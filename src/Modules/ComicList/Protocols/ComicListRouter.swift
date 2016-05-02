//
//  ComicListRouter.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 01/05/16.
//
//

protocol ComicListRouter {
    func handleComicSelected(comicIdentifier: ComicIdentifier, comic: Comic?)
}
