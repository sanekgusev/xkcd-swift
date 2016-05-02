
/// A collection of key-value pairs with defined ordering.
public struct OrderedDictionary<Key: Hashable, Value>: RangeReplaceableCollectionType {
    
    public typealias KeyValuePair = (key: Key, value: Value)
    public typealias IndexValuePair = (index: Index, value: Value)
    public typealias IndexKeyValuePair = (index: Index, key: Key, value: Value)
    
    public typealias Element = KeyValuePair
    public typealias Index = Int

    private var array = [Element]()
    private var dictionary = [Key: Index]()

    /// Construct an empty ordered dictionary.
    public init() {}
    
    /// Construct an ordered dictionary from the elements of arbitrary sequence 
    /// of key-value pairs.
    public init<S: SequenceType where S.Generator.Element == Element>(_ s: S) {
        replaceRange(0..<0, with: s)
    }
    
    /// Always zero, which is the index of the first key-value pair
    /// when non-empty.
    public var startIndex: Index {
        return array.startIndex
    }
    
    /// A "past-the-end" element index; the successor of the last valid
    /// subscript argument.
    public var endIndex: Index {
        return array.endIndex
    }
    
    /// Return key-value pair at `index`.
    /// - Complexity: O(1).
    public subscript (index: Index) -> Element {
        return array[index]
    }

    /// Return index-value pair for `key`, or `nil` if `key` is not present 
    /// in the dictionary
    public subscript (key: Key) -> IndexValuePair? {
        get {
            guard let index = dictionary[key] else {
                return nil
            }
            return (index, array[index].value)
        }
    }
    
    /// An ordered collection containing just the keys of `self`.
    public var keys: LazyMapCollection<OrderedDictionary, Key> {
        return self.lazy.map({ $0.key })
    }
    
    /// An ordered collection containing just the values of `self`.
    public var values: LazyMapCollection<OrderedDictionary, Value> {
        return self.lazy.map({ $0.value })
    }
    
    /// Remove a given key and the associated value from the dictionary,
    /// Returns an index-key-value tuple that was removed, 
    /// or `nil` if the key was not present in the dictionary.
    ///
    /// Invalidates all indices with respect to `self`.
    public mutating func removeForKey(key: Key) -> IndexKeyValuePair? {
        guard let index = dictionary[key] else {
            return nil
        }
        let (key, value) = removeAtIndex(index)
        return (index, key, value)
    }
    
    /// Update the value stored in the dictionary for the given key, or, if they
    /// key does not exist, append a new key-value pair to the end of 
    /// ordered dictionary.
    ///
    /// Returns the index-key-value tuple that had its value replaced, 
    /// or `nil` if a new key-value pair was appended.
    public mutating func updateValue(value: Value, forKey key: Key) -> IndexKeyValuePair? {
        guard let index = dictionary[key] else {
            append((key, value))
            return nil
        }
        let oldKeyValue = array[index]
        array[index] = (key, value)
        dictionary[key] = index
        return (index, oldKeyValue.key, oldKeyValue.value)
    }

    /// Replace the given `subRange` of elements with `newElements`.
    public mutating func replaceRange<S: SequenceType where S.Generator.Element == Element>(subRange: Range<Index>, with newElements: S) {
        subRange.forEach { index in
            dictionary.removeValueForKey(array[index].key)
        }
        array.removeRange(subRange)
        
        var index = subRange.startIndex;
        newElements.forEach { element in
            if dictionary[element.key] == nil {
                dictionary[element.key] = index;
                array.insert(element, atIndex: index)
                index += 1;
            }
        }
    }
}

extension OrderedDictionary: ArrayLiteralConvertible {
    /// Create an instance containing `elements`.
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension OrderedDictionary: DictionaryLiteralConvertible {
    /// Create an instance containing `elements`.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements.map({ $0 as Element }))
    }
}

extension OrderedDictionary: CustomStringConvertible, CustomDebugStringConvertible {
    /// A textual representation of `self`.
    public var description: String {
        var description = dropLast().reduce("[", combine: { $0 + "\($1.key): \($1.value), " })
        if let last = last {
            description += "\(last.key): \(last.value)"
        }
        description += "]"
        return description
    }
    
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return "array: \(String(reflecting: array))\ndictionary: \(String(reflecting:dictionary))"
    }
}