//
//  CancellableAsynchronousTask.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 5/16/15.
//
//

import Foundation

public final class CancellableAsynchronousTask<T> : AsynchronousTask<T> {
    
    private let _cancelBlock: () -> ()
    
    public init(spawnBlock: (completionBlock: (result: T) -> ()) -> (),
        cancelBlock:() -> ()) {
        _cancelBlock = cancelBlock
        super.init(spawnBlock: spawnBlock)
    }
    
    public func cancel() {
        _cancelBlock()
    }
}
