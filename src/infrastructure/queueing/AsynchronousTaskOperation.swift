//
//  AsynchronousTaskBlockOperation.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/11/15.
//
//

import Foundation
import Dispatch

class AsynchronousTaskOperation<T>: NSOperation {
    
    // MARK: Ivars
    
    private let _asynchronousTask: AsynchronousTask<T>
    
    // MARK: Init
    
    init(asynchronousTask: AsynchronousTask<T>) {
        _asynchronousTask = asynchronousTask
    }
    
    // MARK: Overrides
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        _asynchronousTask.addResultObserverWithHandler({ result in
            dispatch_semaphore_signal(semaphore)
        })
        _asynchronousTask.start()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
}