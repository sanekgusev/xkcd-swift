//
//  AsynchronousTask.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 5/16/15.
//
//

import Foundation
import Dispatch

public class AsynchronousTask<T> {
    
    private var _spawnBlock: ((completionBlock: (result: T) -> ()) -> ())?
    private let _observerSet = ObserverSet<T>()
    private let _semaphore: dispatch_semaphore_t
    
    public init(spawnBlock: (completionBlock: (result: T) -> ()) -> ()) {
        _spawnBlock = spawnBlock
        _semaphore = dispatch_semaphore_create(1)
    }
    
    public func start() {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
        if let spawnBlock = _spawnBlock {
            _spawnBlock = nil
            spawnBlock(completionBlock: { result in
                self._observerSet.notify(result)
            })
        }
        else {
            assert(false, "cannot invoke start() more than once")
        }
        dispatch_semaphore_signal(_semaphore)
    }
    
    public func addResultObserverWithHandler(handler: (result: T) -> ()) -> Any {
        return _observerSet.add(handler)
    }
    
    public func removeResultObserver(observer: Any) {
        if let observer = observer as? ObserverSetEntry<T> {
            _observerSet.remove(observer)
        }
    }
}