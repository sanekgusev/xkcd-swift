//
//  NSURLSessionTask+Cancellable.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 2/22/15.
//
//

import Foundation

extension NSURLSessionTask : AsyncCancellable {
    func start() {
        resume()
    }
}