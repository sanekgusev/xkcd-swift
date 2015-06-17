//
//  AsynchronousTask.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 5/16/15.
//
//

import Foundation
import Dispatch

private enum AsynchronousTaskState {
    case NotStarted
    case Running
    case Finished
}

public class AsynchronousTask<T> : Hashable {
    
    // MARK: ivars
    
    private let _spawnBlock: ((completionBlock: (result: T) -> ()) -> ())
    private let _observerSet = ObserverSet<T>()
    private var _state = AsynchronousTaskState.NotStarted
    private let _serialQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    
    // MARK: init
    
    public init(spawnBlock: (completionBlock: (result: T) -> ()) -> ()) {
        _spawnBlock = spawnBlock
    }
    
    // MARK: public
    
    public func start() {
        dispatch_async(_serialQueue, { () -> Void in
            switch self._state {
            case .NotStarted:
                self._spawnBlock(completionBlock: { result in
                    dispatch_async(self._serialQueue, { () -> Void in
                        self._state = .Finished
                        self._observerSet.notify(result)
                    })
                })
                self._state = .Running
            default:
                assert(false, "cannot invoke start() more than once")
            }
        })
    }
    
    public func addResultObserverWithHandler(handler: (result: T) -> ()) -> Any {
        return _observerSet.add(handler)
    }
    
    public func removeResultObserver(observer: Any) {
        if let observer = observer as? ObserverSetEntry<T> {
            _observerSet.remove(observer)
        }
    }
    
    // MARK: Hashable
    
    public var hashValue: Int {
        return unsafeBitCast(_spawnBlock, Int.self)
    }
}

public func ==<T>(lhs: AsynchronousTask<T>, rhs: AsynchronousTask<T>) -> Bool {
    return unsafeBitCast(lhs._spawnBlock, Int.self) == unsafeBitCast(rhs._spawnBlock, Int.self)
}