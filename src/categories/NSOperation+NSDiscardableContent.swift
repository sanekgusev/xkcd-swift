//
//  NSOperation+NSDiscardableContent.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 4/8/15.
//
//

import Foundation

extension NSOperation : NSDiscardableContent {
    
    public func beginContentAccess() -> Bool {
        return !isContentDiscarded()
    }
    
    public func endContentAccess() {}
    
    public func discardContentIfPossible() {
        self.cancel()
    }
    
    public func isContentDiscarded() -> Bool {
        return self.finished
    }
    
}