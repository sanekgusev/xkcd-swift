//
//  ReactiveComicWrapper.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 04/05/16.
//
//
import ReactiveCocoa

//protocol ReactiveEntityWrapper {
//    associatedtype Identifier
//    associatedtype Entity
//    associatedtype Error: ErrorType
//    var identifier: Identifier { get }
//    var entity: AnyProperty<Entity?> { get }
//    var loading: AnyProperty<Bool> { get }
//    var lastLoadError: AnyProperty<Error?> { get }
//    
//    func retrieveEntityWithSignal(@noescape setUp: (Signal<Entity, Error>, Disposable) -> ())
//}
//
//protocol ReactiveComicWrapper: ReactiveEntityWrapper {
//    associatedtype Identifier = ComicIdentifier
//    associatedtype Entity = Comic
//    associatedtype Error = ComicRepositoryError
//}

protocol ReactiveComicWrapper {
    var comicIdentifier: ComicIdentifier { get }
    var comic: AnyProperty<Comic?> { get }
    var loading: AnyProperty<Bool> { get }
    var lastLoadError: AnyProperty<ComicRepositoryError?> { get }
    
    func retrieveComicWithSignal(@noescape setUp: (Signal<Comic, ComicRepositoryError>, Disposable) -> ())
}