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
    
    init(cancellableAsynchronousTask: CancellableAsynchronousTask<T>) {
        _cancellableAsynchronousTask = cancellableAsynchronousTask
    }
    
    // MARK: Overrides
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        _cancellableAsynchronousTask.addResultObserverWithHandler({ result in
            dispatch_semaphore_signal(semaphore)
        })
        _cancellableAsynchronousTask.addCancelledObserverWithHandler({
            dispatch_semaphore_signal(semaphore)
        })
        _cancellableAsynchronousTask.start()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    override func cancel() {
        super.cancel()
        _cancellableAsynchronousTask.cancel()
    }
}