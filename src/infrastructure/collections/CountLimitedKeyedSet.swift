//
//  CountLimitedKeyedSet.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 5/26/15.
//
//

import Foundation

public final class CountLimitedKeyedSet<Key: Hashable, Value where Value: Hashable, Value: UniquelyIdentifiable, Value.Identifier == Key> {
    
    private let _keyedSet : KeyedSet<Key, Value>
    
    public init() {
        _keyedSet = KeyedSet()
    }
    
}
