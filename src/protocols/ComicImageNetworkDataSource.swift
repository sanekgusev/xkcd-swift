//
//  ComicImageDataSource.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/25/15.
//
//

import Foundation

enum ComicImageNetworkDataSourceResult {
    case Success(NSURL)
    case Failure(NSError?)
}

enum ComicImageNetworkDataSourceAsyncResult {
    case Success(AsyncCancellable)
    case Failure(NSError?)
}

protocol ComicImageNetworkDataSource {
    func retrieveImageForComic(comic: Comic,
        imageKind: ComicImageKind,
        completion: (result: Result<NSURL>) -> ()) -> ComicImageNetworkDataSourceAsyncResult
}