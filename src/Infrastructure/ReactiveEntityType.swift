//
//  ReactiveEntity.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 18/06/16.
//
//

import ReactiveCocoa

protocol ReactiveEntityType {
    associatedtype Identifier
    associatedtype Entity
    associatedtype Error: ErrorType
    
    var entity: AnyProperty<Entity?> { get }
    var isFetching: AnyProperty<Bool> { get }
    var lastFetchError: AnyProperty<Error?> { get }
    
    var identifier: Identifier { get }
    
    func refetchWithSignal(setUp: (Signal<Entity, Error>, Disposable) -> ())
}

extension ReactiveEntityType {
    func refetch() {
        refetchWithSignal { _, _ in }
    }
}