//
//  AnyReactiveEntity.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 04/07/16.
//
//

import ReactiveCocoa

struct AnyReactiveEntity <Identifier, Entity, Error: ErrorType>: ReactiveEntityType {
    
    private let _identifier: () -> Identifier
    private let _entity: () -> AnyProperty<Entity?>
    private let _isFetching: () -> AnyProperty<Bool>
    private let _lastFetchError: () -> AnyProperty<Error?>
    private let _refetchWithSignal: (setUp: (Signal<Entity, Error>, Disposable) -> ()) -> Void
    
    init<R: ReactiveEntityType where R.Identifier == Identifier, R.Entity == Entity, R.Error == Error>(_ reactiveEntity: R) {
        _identifier = { reactiveEntity.identifier }
        _entity = { reactiveEntity.entity }
        _isFetching = { reactiveEntity.isFetching }
        _lastFetchError = { reactiveEntity.lastFetchError }
        _refetchWithSignal = { setUp in
            reactiveEntity.refetchWithSignal(setUp)
        }
    }
    
    var identifier: Identifier {
        return _identifier()
    }
    
    var entity: AnyProperty<Entity?> {
        return _entity()
    }
    
    var isFetching: AnyProperty<Bool> {
        return _isFetching()
    }
    
    var lastFetchError: AnyProperty<Error?> {
        return _lastFetchError()
    }
    
    func refetchWithSignal(setUp: (Signal<Entity, Error>, Disposable) -> ()) {
        _refetchWithSignal(setUp: setUp)
    }
}