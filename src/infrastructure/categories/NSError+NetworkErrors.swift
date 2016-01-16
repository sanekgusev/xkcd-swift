//
//  NSError+NetworkErrors.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 1/15/16.
//
//

import Foundation

extension NSError {
    var isNetworkError: Bool {
        return isErrorInDomain(NSURLErrorDomain, withCodeInSet: Set<Int>()); // TODO
    }
    
    var isServerError: Bool {
        return isErrorInDomain(NSURLErrorDomain, withCodeInSet: Set<Int>()); // TODO
    }
    
    private func isErrorInDomain(domain: String, withCodeInSet set: Set<Int>) -> Bool {
        if (self.domain != domain) {
            return false;
        }
        return set.contains(code);
    }
}