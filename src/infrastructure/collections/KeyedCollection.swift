//
//  KeyedCollection.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 4/12/15.
//
//

public protocol UniquelyIdentifiable {
    typealias Identifier
    
    var identifier: Identifier { get }
}

public struct KeyedCollection<Key: Hashable, Value where Value: UniquelyIdentifiable, Value.Identifier == Key> :
    CollectionType {
    
    typealias Index = DictionaryIndex<Key, Value>
    typealias Generator = DictionaryGenerator<Key, Value>
    
    // MARK: ivars
    
    public private(set) var keys: Set<Key>
    private var _valuesForKeys: Dictionary<Key, Value>
    
    // MARK: initializers
    
    public init(minimumCapacity: Int) {
        keys = Set(minimumCapacity: minimumCapacity)
        _valuesForKeys = Dictionary(minimumCapacity: minimumCapacity)
    }
    
    public init() {
        self.init(minimumCapacity: 0)
    }
    
    public init<S : SequenceType where S.Generator.Element == Value>(_ sequence: S) {
        self.init()
        for value in sequence {
            let key = value.identifier
            keys.insert(key);
            _valuesForKeys[key] = value
        }
    }
    
    // MARK: CollectionType

    public var startIndex: Index {
        return _valuesForKeys.startIndex
    }
    
    public var endIndex: Index {
        return _valuesForKeys.endIndex
    }
    
    public func generate() -> Generator {
        return _valuesForKeys.generate()
    }
    
    public subscript (position: Index) -> (Key, Value) {
        return _valuesForKeys[position]
    }
    
    // MARK: indexes
    
    public func indexForKey(key: Key) -> Index? {
        return _valuesForKeys.indexForKey(key)
    }
    
    public mutating func removeAtIndex(index: Index) {
        let (key, _) = self[index]
        removeValueForKey(key)
    }
    
    // MARK: public
    
    public var values: LazyForwardCollection<MapCollectionView<[Key : Value], Value>> {
        return _valuesForKeys.values;
    }
    
    public subscript (key: Key) -> Value? {
        return _valuesForKeys[key]
    }
    
    public func contains(value: Value) -> Bool {
        return keys.contains(value.identifier)
    }
    
    public mutating func tryInsert(value: Value) -> Bool {
        if (!keys.contains(value.identifier)) {
            keys.insert(value.identifier)
            _valuesForKeys[value.identifier] = value
            return true
        }
        return false
    }
    
    public mutating func update(value: Value) -> Value? {
        let previousValue = _valuesForKeys[value.identifier]
        if let previousValue = previousValue {
            keys.remove(previousValue.identifier)
            _valuesForKeys.removeValueForKey(previousValue.identifier)
        }
        tryInsert(value)
        return previousValue
    }
    
    public mutating func remove(value: Value) -> Value? {
        return removeValueForKey(value.identifier);
    }
    
    public mutating func removeValueForKey(key: Key) -> Value? {
        let removedValue = _valuesForKeys.removeValueForKey(key)
        if let removedValue = removedValue {
            keys.remove(removedValue.identifier)
        }
        return removedValue
    }
    
    public mutating func removeAll(keepCapacity: Bool = false) {
        keys.removeAll(keepCapacity: keepCapacity)
        _valuesForKeys.removeAll(keepCapacity: keepCapacity)
    }
    
    public var count: Int {
        return keys.count
    }
    
    public var isEmpty: Bool {
        return keys.isEmpty
    }
    
    // MARK: set operations
    
    public func isSubsetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return keys.isSubsetOf(sequence)
    }
    
    public func isSubsetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isSubsetOf(map(sequence, { $0.identifier }))
    }
    
    public func isStrictSubsetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return keys.isStrictSubsetOf(sequence)
    }
    
    public func isStrictSubsetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isStrictSubsetOf(map(sequence, { $0.identifier }))
    }
    
    public func isSupersetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return keys.isSupersetOf(sequence)
    }
    
    public func isSupersetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isSupersetOf(map(sequence, { $0.identifier }))
    }
    
    public func isStrictSupersetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return keys.isStrictSupersetOf(sequence)
    }
    
    public func isStrictSupersetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isStrictSupersetOf(map(sequence, { $0.identifier }))
    }
    
    public func isDisjointWith<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return keys.isDisjointWith(sequence)
    }
    
    public func isDisjointWith<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isDisjointWith(map(sequence, { $0.identifier }))
    }
    
    // MARK:
    
    public func union<S : SequenceType where S.Generator.Element == Value>(sequence: S, updateExisting: Bool = false) -> KeyedCollection<Key, Value> {
        var collection = self
        collection.unionInPlace(sequence, updateExisting: updateExisting)
        return collection
    }
    
    public mutating func unionInPlace<S : SequenceType where S.Generator.Element == Value>(sequence: S, updateExisting: Bool = false) {
        for value in sequence {
            if updateExisting {
                self.update(value)
            }
            else {
                self.tryInsert(value)
            }
        }
    }
    
    public func subtract<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> KeyedCollection<Key, Value> {
        var collection = self
        collection.subtractInPlace(sequence)
        return collection
    }
    
    public mutating func subtractInPlace<S : SequenceType where S.Generator.Element == Value>(sequence: S) {
        let sequenceKeys = map(sequence, { $0.identifier })
        subtractInPlace(sequenceKeys)
    }
    
    public func subtract<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> KeyedCollection<Key, Value> {
        var collection = self
        collection.subtractInPlace(sequence)
        return collection
    }
    
    public mutating func subtractInPlace<S : SequenceType where S.Generator.Element == Key>(sequence: S) {
        let keysToDelete = keys.intersect(sequence)
        keys.subtractInPlace(sequence)
        for key in keysToDelete {
            _valuesForKeys.removeValueForKey(key)
        }
    }
    
    public func intersect<S : SequenceType where S.Generator.Element == Value>(sequence: S, updateExisting: Bool = false) -> KeyedCollection<Key, Value> {
        var collection = self
        collection.intersectInPlace(sequence, updateExisting:updateExisting)
        return collection
    }
    
    public mutating func intersectInPlace<S : SequenceType where S.Generator.Element == Value>(sequence: S, updateExisting: Bool = false) {
        let sequenceKeys = map(sequence, { $0.identifier })
        intersectInPlace(sequenceKeys)
        if updateExisting {
            for value in sequence {
                if _valuesForKeys[value.identifier] != nil {
                    _valuesForKeys.updateValue(value, forKey: value.identifier)
                }
            }
        }
    }
    
    public func intersect<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> KeyedCollection<Key, Value> {
        var collection = self
        collection.intersectInPlace(sequence)
        return collection
    }
    
    public mutating func intersectInPlace<S : SequenceType where S.Generator.Element == Key>(sequence: S) {
        let keysToDelete = keys.subtract(sequence)
        for key in keysToDelete {
            _valuesForKeys.removeValueForKey(key)
        }
        keys.intersectInPlace(sequence)
    }
    
    public func exclusiveOr<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> KeyedCollection<Key, Value> {
        var collection = self
        collection.exclusiveOr(sequence)
        return collection
    }

    public mutating func exclusiveOrInPlace<S : SequenceType where S.Generator.Element == Value>(sequence: S) {
        for value in sequence {
            self.tryInsert(value)
        }
        
        let sequenceKeys = map(sequence, { $0.identifier })
        let keysToDelete = keys.intersect(sequenceKeys)
        for key in keysToDelete {
            _valuesForKeys.removeValueForKey(key)
        }
        keys.exclusiveOrInPlace(sequenceKeys)
    }
}

extension KeyedCollection : Printable, DebugPrintable {
    
    public var description: String {
        return "Keys: \(keys.description)\n" +
        "Values for keys: \(_valuesForKeys.description)"
    }
    
    public var debugDescription: String {
        return "Keys: \(keys.debugDescription)\n" +
        "Values for keys: \(_valuesForKeys.debugDescription)"
    }
}

extension KeyedCollection: ArrayLiteralConvertible {
    typealias Element = Value
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension KeyedCollection: Hashable {
    public var hashValue: Int {
        return keys.hashValue
    }
}

public func ==<Key, Value>(lhs: KeyedCollection<Key, Value>, rhs: KeyedCollection<Key, Value>) -> Bool {
    return lhs.keys == rhs.keys
}