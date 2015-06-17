//
//  LimitedConcurrentTaskQueue.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/6/15.
//
//

import Foundation
import Dispatch

public final class LimitedConcurrentTaskQueue<T> {
    
    // MARK: ivars
    
    private let _operationQueue = NSOperationQueue()
    private var _taskTrackingQueue = UniquedQueue<AsynchronousTask<T>>()
    private var _operationsForTasks = Dictionary<AsynchronousTask<T>, AsynchronousTaskOperation<T>>()
    private let _serialQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    
    // MARK: properties
    
    public var maxConcurrentTaskCount : Int? {
        get {
            return _operationQueue.maxConcurrentOperationCount == NSOperationQueueDefaultMaxConcurrentOperationCount ?
                nil : _operationQueue.maxConcurrentOperationCount
        }
        set {
            _operationQueue.maxConcurrentOperationCount = newValue ?? NSOperationQueueDefaultMaxConcurrentOperationCount
        }
    }
    
    public var maxQueueLength : Int? {
        didSet {
            dispatch_async(_serialQueue, { () -> Void in
                self.cancelOldOperationsIfNeeded()
            })
        }
    }
    
    // MARK: public
    
    public func taskForEnqueueingTask(task: AsynchronousTask<T>,
        queuePriority: NSOperationQueuePriority = .Normal,
        qualityOfService: NSQualityOfService = .Background) -> CancellableAsynchronousTask<T> {
            
        return taskForEnqueueingTask(task,
            wrappingOperation: AsynchronousTaskOperation(asynchronousTask: task),
            queuePriority: queuePriority,
            qualityOfService: qualityOfService)
    }
    
    public func taskForEnqueueingTask(task: CancellableAsynchronousTask<T>,
        queuePriority: NSOperationQueuePriority = .Normal,
        qualityOfService: NSQualityOfService = .Background) -> CancellableAsynchronousTask<T> {
        
        return taskForEnqueueingTask(task,
            wrappingOperation: CancellableAsynchronousTaskOperation(cancellableAsynchronousTask: task),
            queuePriority: queuePriority,
            qualityOfService: qualityOfService)
    }
    
    // MARK: private
    
    private func taskForEnqueueingTask(task: AsynchronousTask<T>,
        wrappingOperation: AsynchronousTaskOperation<T>,
        queuePriority: NSOperationQueuePriority,
        qualityOfService: NSQualityOfService) -> CancellableAsynchronousTask<T> {
            
        wrappingOperation.queuePriority = queuePriority
        wrappingOperation.qualityOfService = qualityOfService
        wrappingOperation.completionBlock = { () in
            dispatch_async(self._serialQueue, { () -> Void in
                self._taskTrackingQueue.remove(task)
                self._operationsForTasks.removeValueForKey(task)
            })
        }
        return CancellableAsynchronousTask(spawnBlock: { completionBlock in
            task.addResultObserverWithHandler(completionBlock)
            self._operationQueue.addOperation(wrappingOperation)
            dispatch_async(self._serialQueue, { () -> Void in
                self._taskTrackingQueue.pushBack(task)
                self._operationsForTasks[task] = wrappingOperation
                self.cancelOldOperationsIfNeeded()
            })
            }, cancelBlock: { () in
                wrappingOperation.cancel()
            })
    }
    
    private func cancelOldOperationsIfNeeded() {
        if let maxQueueLength = maxQueueLength {
            let numberOfOperationsToCancel = _taskTrackingQueue.count - maxQueueLength
            if numberOfOperationsToCancel > 0 {
                let tasksToCancel = _taskTrackingQueue.popFront(numberOfOperationsToCancel)
                for task in tasksToCancel {
                    if let operation = _operationsForTasks.removeValueForKey(task) {
                        operation.cancel()
                    }
                }
            }
        }
    }
}