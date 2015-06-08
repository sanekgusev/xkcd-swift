//
//  NSBlockOperation+AsynchronousTasks.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 6/3/15.
//
//

import Foundation
import Dispatch

extension NSBlockOperation  {
    
    public convenience init<T>(asynchronousTask: AsynchronousTask<T>) {
        self.init(block: {
            let semaphore = dispatch_semaphore_create(0)
            asynchronousTask.addResultObserverWithHandler({ result in
                dispatch_semaphore_signal(semaphore)
            })
            asynchronousTask.start()
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        })
    }
    
}