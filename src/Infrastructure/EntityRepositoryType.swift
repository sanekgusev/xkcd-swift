//
//  EntityFetcher.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 04/07/16.
//
//

import ReactiveCocoa

protocol EntityRepositoryType {
    associatedtype Identifier
    associatedtype Entity
    associatedtype Error: ErrorType
    
    func fetchEntity(identifier: Identifier) -> SignalProducer<Entity, Error>
}
