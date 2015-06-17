//
//  CancellableAsynchronousTask.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 5/16/15.
//
//

import Foundation

private enum CancellableAsynchronousTaskState {
    case NotStarted
    case Running
    case Finished
}

public final class CancellableAsynchronousTask<T> : AsynchronousTask<T> {
    
    // MARK: ivars
    
    private let _spawnBlock: ((completionBlock: (result: T) -> ()) -> ())
    private let _cancelBlock: () -> ()
    private var _state = CancellableAsynchronousTaskState.NotStarted
    private let _completedObserverSet = ObserverSet<T>()
    private let _cancelledObserverSet = ObserverSet<Void>()
    private let _serialQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)
    
    // MARK: init
    
    public init(spawnBlock: (completionBlock: (result: T) -> ()) -> (),
        cancelBlock:() -> ()) {
        _spawnBlock = spawnBlock
        _cancelBlock = cancelBlock
        super.init(spawnBlock: spawnBlock)
    }
    
    // MARK: public
    
    public override func start() {
        dispatch_async(_serialQueue, { () -> Void in
            switch self._state {
            case .NotStarted:
                self._spawnBlock(completionBlock: { result in
                    dispatch_async(self._serialQueue, { () -> Void in
                        switch self._state {
                        case .Running:
                            self._state = .Finished
                            self._completedObserverSet.notify(result)
                        default: ()
                        }
                    })
                })
                self._state = .Running
            default:
                assert(false, "cannot invoke start() more than once")
            }
        })
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
        dispatch_async(_serialQueue, { () -> Void in
            switch self._state {
                case .Running:
                    self._cancelBlock()
                    self._state = .Finished
                    self._cancelledObserverSet.notify()
                default: ()
            }
        })
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
