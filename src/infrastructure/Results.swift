//
//  Result.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/13/15.
//
//

import Foundation

enum Result<T: AnyObject> {
    case Success(T)
    case Failure(NSError?)
}

enum VoidResult {
    case Success
    case Failure(NSError?)
}