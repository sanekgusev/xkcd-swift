//
//  CancellableAsynchronousTaskOperation.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/11/15.
//
//

import Foundation

class CancellableAsynchronousTaskOperation<T>: AsynchronousTaskOperation<T> {
    
    // MARK: Ivars
    
    private let _cancellableAsynchronousTask: CancellableAsynchronousTask<T>
    
    // MARK: Init
    
    required init(cancellableAsynchronousTask: CancellableAsynchronousTask<T>) {
        _cancellableAsynchronousTask = cancellableAsynchronousTask
        super.init(asynchronousTask: cancellableAsynchronousTask)
    }
    
    // MARK: Overrides
    
    override func cancel() {
        super.cancel()
        _cancellableAsynchronousTask.cancel()
    }
}