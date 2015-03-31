//
//  Cancellable.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/22/15.
//
//

protocol AsyncCancellable: AsyncStartable {
    func cancel()
}