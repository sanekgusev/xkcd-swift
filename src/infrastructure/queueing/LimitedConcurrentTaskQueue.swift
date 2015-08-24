//
//  LimitedConcurrentTaskQueue.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/6/15.
//
//

import Foundation
import Dispatch
import SwiftTask

public enum LimitedConcurrentTaskQueueError : ErrorType {
    case TaskNotPaused
}

public final class LimitedConcurrentTaskQueue<Progress, Value, Error> {
    
    // MARK: ivars
    
    private lazy var operationQueue: NSOperationQueue = {
        let operationQueue = NSOperationQueue()
        operationQueue.name = "com.sanekgusev.LimitedConcurrentTaskQueue"
        return operationQueue
    }()
    private lazy var taskTrackingQueue = [Task<Progress, Value, Error>]()
    private lazy var operationsForTasks = Dictionary<Task<Progress, Value, Error>, TaskOperation<Progress, Value, Error>>()
    private lazy var synchronizationQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    
    // MARK: properties
    
    public var qualityOfService: NSQualityOfService {
        get {
            return operationQueue.qualityOfService
        }
        set {
            operationQueue.qualityOfService = newValue
        }
    }
    
    public var maxConcurrentTaskCount : Int? {
        get {
            return operationQueue.maxConcurrentOperationCount == NSOperationQueueDefaultMaxConcurrentOperationCount ?
                nil : operationQueue.maxConcurrentOperationCount
        }
        set {
            operationQueue.maxConcurrentOperationCount = newValue ?? NSOperationQueueDefaultMaxConcurrentOperationCount
        }
    }
    
    public var maxQueueLength : Int? {
        didSet {
            dispatch_async(synchronizationQueue, { _ in
                self.cancelOldOperationsIfNeeded()
            })
        }
    }
    
    // MARK: public
    
    public func taskForEnqueueingTask(task: Task<Progress, Value, Error>,
        queuePriority: NSOperationQueuePriority = .Normal,
        qualityOfService: NSQualityOfService = .Background) throws -> Task<Progress, Value, Error> {
        
            if task.state != .Paused {
                throw LimitedConcurrentTaskQueueError.TaskNotPaused
            }
            
            return taskForEnqueueingTask(task,
                wrappingOperation: TaskOperation(task: task),
                queuePriority: queuePriority,
                qualityOfService: qualityOfService)
    }
    
    // MARK: private
    
    private func taskForEnqueueingTask(task: Task<Progress, Value, Error>,
        wrappingOperation: TaskOperation<Progress, Value, Error>,
        queuePriority: NSOperationQueuePriority,
        qualityOfService: NSQualityOfService) -> Task<Progress, Value, Error> {
            
        wrappingOperation.queuePriority = queuePriority
        wrappingOperation.qualityOfService = qualityOfService
        wrappingOperation.completionBlock = { () in
            dispatch_async(self.synchronizationQueue, { _ in
                self.taskTrackingQueue.removeAtIndex(self.taskTrackingQueue.indexOf({ $0 == task })!)
                self.operationsForTasks.removeValueForKey(task)
            })
        }
        return Task(weakified: false,
            paused: true,
            initClosure: { (progress, fulfill, reject, configure) -> Void in
                configure.resume = {
                    task.then({ (value, errorInfo) -> Void in
                        if let value = value {
                            fulfill(value)
                        }
                        else if let error = errorInfo?.error {
                            reject(error)
                        }
                        // TODO: handle cancellations of inner task?
                    })
                    task.progress({ (oldProgress, newProgress) -> Void in
                        progress(newProgress)
                    })
                    self.operationQueue.addOperation(wrappingOperation)
                    dispatch_async(self.synchronizationQueue, { _ in
                        self.taskTrackingQueue.append(task)
                        self.operationsForTasks[task] = wrappingOperation
                        self.cancelOldOperationsIfNeeded()
                    })
                }
                configure.cancel = wrappingOperation.cancel
            })
    }
    
    private func cancelOldOperationsIfNeeded() {
        guard let maxQueueLength = maxQueueLength else {
            return;
        }
        let numberOfOperationsToCancel = taskTrackingQueue.count - maxQueueLength
        if numberOfOperationsToCancel <= 0 {
            return
        }
        let toBeCancelledRange = Range(start: 0, end: numberOfOperationsToCancel)
        let tasksToCancel = taskTrackingQueue[toBeCancelledRange]
        taskTrackingQueue.removeRange(toBeCancelledRange)
        for task in tasksToCancel {
            if let operation = operationsForTasks.removeValueForKey(task) {
                operation.cancel()
            }
        }
    }
}