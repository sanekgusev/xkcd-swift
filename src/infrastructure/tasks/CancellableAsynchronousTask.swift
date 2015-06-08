//
//  CancellableAsynchronousTask.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 5/16/15.
//
//

import Foundation

public final class CancellableAsynchronousTask<T> : AsynchronousTask<T> {
    
    // MARK: ivars
    
    private let _cancelBlock: () -> ()
    private var _cancelled = false
    private let _semaphore: dispatch_semaphore_t
    
    // MARK: init
    
    public init(spawnBlock: (completionBlock: (result: T) -> ()) -> (),
        cancelBlock:() -> ()) {
        _cancelBlock = cancelBlock
        _semaphore = dispatch_semaphore_create(1)
        super.init(spawnBlock: spawnBlock)
    }
    
    // MARK: public
    
    public func start() -> Bool {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
        var started = false
        if (!_cancelled) {
            super.start()
            started = true
        }
        dispatch_semaphore_signal(_semaphore)
        return started
    }
    
    public override func start() {
        let _ = start()
    }
    
    public func cancel() {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
        _cancelled = true
        _cancelBlock()
        dispatch_semaphore_signal(_semaphore)
    }
}
