//
//  Task+Hashable.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 7/27/15.
//
//

import Foundation
import SwiftTask

extension Task : Hashable {
    
    public var hashValue: Int {
        return unsafeBitCast(self, Int.self)
    }
}

public func ==<Progress, Value, Error>(lhs: Task<Progress, Value, Error>, rhs: Task<Progress, Value, Error>) -> Bool {
    return unsafeAddressOf(lhs) == unsafeAddressOf(rhs)
}