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
    
    private var _spawnBlock: ((completionBlock: (result: T) -> ()) -> ())?
    private var _cancelBlock: () -> ()
    private var _finished = false
    private let _completedObserverSet = ObserverSet<T>()
    private let _cancelledObserverSet = ObserverSet<Void>()
    private let _semaphore = dispatch_semaphore_create(1)
    private let _completionSemaphore = dispatch_semaphore_create(1)
    
    // MARK: init
    
    public init(spawnBlock: (completionBlock: (result: T) -> ()) -> (),
        cancelBlock:() -> ()) {
        _spawnBlock = spawnBlock
        _cancelBlock = cancelBlock
    }
    
    // MARK: public
    
    public override func start() {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
        if !_finished {
            if let spawnBlock = _spawnBlock {
                _spawnBlock = nil
                spawnBlock(completionBlock: { result in
                    var shouldNotifyObservers = false
                    dispatch_semaphore_wait(self._completionSemaphore, DISPATCH_TIME_FOREVER)
                    if !self._finished {
                        shouldNotifyObservers = true
                    }
                    dispatch_semaphore_signal(self._completionSemaphore)
                    if shouldNotifyObservers {
                        self._completedObserverSet.notify(result)
                    }
                })
            }
            else {
                assert(false, "cannot invoke start() more than once")
            }
        }
        dispatch_semaphore_signal(_semaphore)
    }
    
    public override func addResultObserverWithHandler(handler: (result: T) -> ()) -> Any {
        return _completedObserverSet.add(handler)
    }
    
    public override func removeResultObserver(observer: Any) {
        if let observer = observer as? ObserverSetEntry<T> {
            _completedObserverSet.remove(observer)
        }
    }
    
    public func cancel() {
        var shouldNotifyObservers = false
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER)
        dispatch_semaphore_wait(_completionSemaphore, DISPATCH_TIME_FOREVER)
        if !_finished {
            _finished = true;
            _cancelBlock()
            shouldNotifyObservers = true
        }
        dispatch_semaphore_signal(_completionSemaphore)
        dispatch_semaphore_signal(_semaphore)
        if shouldNotifyObservers {
            _cancelledObserverSet.notify()
        }
    }
    
    public func addCancelledObserverWithHandler(handler: () -> ()) -> Any {
        return _cancelledObserverSet.add(handler)
    }
    
    public func removeCancelledObserver(observer: Any) {
        if let observer = observer as? ObserverSetEntry<Void> {
            _cancelledObserverSet.remove(observer)
        }
    }
    
    // MARK: Hashable
    
    public override var hashValue: Int {
        let prime = 31
        var result = 1
        result = prime * result + unsafeBitCast(_spawnBlock, Int.self)
        result = prime * result + unsafeBitCast(_cancelBlock, Int.self)
        return result
    }
}

public func ==<T>(lhs: CancellableAsynchronousTask<T>, rhs: CancellableAsynchronousTask<T>) -> Bool {
    return unsafeBitCast(lhs._spawnBlock, Int.self) == unsafeBitCast(rhs._spawnBlock, Int.self) &&
        unsafeBitCast(lhs._cancelBlock, Int.self) == unsafeBitCast(rhs._cancelBlock, Int.self)
}
