//
//  AsynchronousTaskBlockOperation.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/11/15.
//
//

import Foundation
import Dispatch
import SwiftTask

final class TaskOperation<Progress, Value, Error>: NSOperation {
    
    // MARK: Ivars
    
    private let task: Task<Progress, Value, Error>
    
    // MARK: Init
    
    init(task: Task<Progress, Value, Error>) {
        self.task = task
    }
    
    // MARK: Overrides
    
    override func main() {
        let semaphore = dispatch_semaphore_create(0)
        task.then { (_, _) in
            dispatch_semaphore_signal(semaphore)
        }
        task.resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
    }
    
    override func cancel() {
        task.cancel()
    }
}