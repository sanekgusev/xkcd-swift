//
//  LimitedConcurrentTaskQueue.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/6/15.
//
//

import Foundation

public final class LimitedConcurrentTaskQueue {
    
    // MARK: ivars
    
    private let _operationQueue = NSOperationQueue()
    
    // MARK: public
    
    public func taskForEnqueueingTask<T>(task: AsynchronousTask<T>) -> CancellableAsynchronousTask<T?> {
        
    }
    
    public func taskForEnqueueingTask<T>(task: CancellableAsynchronousTask<T>) -> CancellableAsynchronousTask<T?> {
        
    }
    
}