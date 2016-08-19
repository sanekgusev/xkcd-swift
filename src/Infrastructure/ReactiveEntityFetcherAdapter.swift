//
//  ReactiveEntityFetcherAdapter.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 04/07/16.
//
//

import ReactiveCocoa

final class ReactiveEntityFetcherAdapter<Identifier, Entity, Error: ErrorType>: ReactiveEntityType {
    
    let identifier: Identifier
    private let _refetch: () -> SignalProducer<Entity, Error>
    
    private let mutableEntity: MutableProperty<Entity?>
    private let mutableIsFetching = MutableProperty<Bool>(false)
    private let mutableLastFetchError = MutableProperty<Error?>(nil)
    
    private var fetchDisposable = SerialDisposable(nil)
    
    init<R: EntityRepositoryType where R.Identifier == Identifier, R.Entity == Entity, R.Error == Error>(repository: R, identifier: Identifier,
         entity: Entity? = nil) {
        self.identifier = identifier
        _refetch = {
            repository.fetchEntity(identifier)
        }
        mutableEntity = MutableProperty(entity)
    }
    
    var entity: AnyProperty<Entity?> {
        return AnyProperty(mutableEntity)
    }
    
    var isFetching: AnyProperty<Bool> {
        return AnyProperty(mutableIsFetching)
    }
    
    var lastFetchError: AnyProperty<Error?> {
        return AnyProperty(mutableLastFetchError)
    }
    
    deinit {
        fetchDisposable.innerDisposable = nil
    }
    
    func refetchWithSignal(setUp: (Signal<Entity, Error>, Disposable) -> ()) {
        _refetch().on(started: {
            self.mutableIsFetching.value = true
            }, failed: { error in
                self.mutableLastFetchError.value = error
            },terminated: {
                self.mutableIsFetching.value = false
            }, next: { comic in
                self.mutableEntity.value = comic
        }).startWithSignal { signal, disposable in
            fetchDisposable.innerDisposable = disposable
            setUp(signal, disposable)
        }
    }
}
