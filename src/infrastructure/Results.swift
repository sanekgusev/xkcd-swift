//
//  Result.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 3/13/15.
//
//

import Foundation

enum Result<T> {
    case Success(T)
    case Failure(NSError?)
}