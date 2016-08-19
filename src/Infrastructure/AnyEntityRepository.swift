//
//  AnyEntityRepository.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 05/07/16.
//
//

import ReactiveCocoa

struct AnyEntityRepository<Identifier, Entity, Error: ErrorType>: EntityRepositoryType {
    
    private let _fetchEntity: (Identifier) -> SignalProducer<Entity, Error>
    
    init<R: EntityRepositoryType where R.Identifier == Identifier, R.Entity == Entity, R.Error == Error>(repository: R) {
        _fetchEntity = { repository.fetchEntity($0) }
    }
    
    func fetchEntity(identifier: Identifier) -> SignalProducer<Entity, Error> {
        return _fetchEntity(identifier)
    }
    
}
