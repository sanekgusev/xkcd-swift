//
//  ConcurrentOperation.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/20/15.
//
//

import Foundation

final class AsynchronousOperation : NSOperation {
    
    // MARK: - Ivars
    
    private let spawnBlock: (completion: () -> ()) -> ()
    private let cancellationBlock: (() -> ())?
    
    // MARK: - Init
    
    init(spawnBlock: (completion: () -> ()) -> (),
        cancellationBlock:(() -> ())?) {
            self.spawnBlock = spawnBlock
            self.cancellationBlock = cancellationBlock
            super.init()
    }
    
    // MARK: - NSOperation
    
    override var asynchronous: Bool {
        return true
    }
    
    private var _executing : Bool = false
    override private(set) var executing : Bool {
        get {
            return _executing
        }
        set {
            if (_executing != newValue) {
                willChangeValueForKey("isExecuting")
                _executing = newValue
                didChangeValueForKey("isExecuting")
            }
        }
    }
    
    private var _finished: Bool = false
    override private(set) var finished: Bool {
        get {
            return _finished
        }
        set {
            if (_finished != newValue) {
                willChangeValueForKey("isFinished")
                _finished = newValue
                didChangeValueForKey("isFinished")
            }
        }
    }
    
    override func start() {
        if (cancelled) {
            finished = true
            return
        }
        
        main()
        
        executing = true
    }
    
    override func cancel() {
        super.cancel()
        cancellationBlock?()
    }
    
    override func main() {
        super.main()
        spawnBlock { () in
            self.completeOperation()
        }
    }
    
    // MARK: - 
    
    func completeOperation() {
        executing = false
        finished  = true
    }
}