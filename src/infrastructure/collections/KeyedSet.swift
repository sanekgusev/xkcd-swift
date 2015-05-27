//
//  KeyedSet.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 4/12/15.
//
//

public protocol UniquelyIdentifiable {
    typealias Identifier
    
    var identifier: Identifier { get }
}

public struct KeyedSet<Key: Hashable, Value where Value: Hashable, Value: UniquelyIdentifiable, Value.Identifier == Key> :
    CollectionType {
    
    typealias Element = Value
    typealias Index = SetIndex<Value>
    typealias Generator = SetGenerator<Value>
    
    private var _values: Set<Value>
    private var _keys: Set<Key>
    private var _valuesForKeys: Dictionary<Key, Value>
    
    public init(minimumCapacity: Int) {
        _values = Set(minimumCapacity: minimumCapacity)
        _keys = Set(minimumCapacity: minimumCapacity)
        _valuesForKeys = Dictionary(minimumCapacity: minimumCapacity)
    }
    
    public init() {
        self.init([])
    }
    
    public init<S : SequenceType where S.Generator.Element == Value>(_ sequence: S) {
        _values = Set<Value>(sequence)
        _keys = Set()
        _valuesForKeys = [:]
        for value in _values {
            let key = value.identifier
            _keys.insert(key);
            _valuesForKeys[key] = value
        }
    }
    
    public var keys: Set<Key> {
        return _keys
    }
    
    public var values: Set<Value> {
        return _values;
    }

    public var startIndex: Index {
        return _values.startIndex
    }
    
    public var endIndex: Index {
        return _values.endIndex
    }
    
    public func generate() -> Generator {
        return _values.generate()
    }
    
    public subscript (position: Index) -> Element {
        return _values[position]
    }
    
    public subscript (key: Key) -> Value? {
        return _valuesForKeys[key]
    }
    
    public func contains(value: Value) -> Bool {
        return _keys.contains(value.identifier)
    }
    
    public func indexOf(value: Value) -> SetIndex<Value>? {
        return _values.indexOf(value)
    }
    
    public mutating func insert(value: Value) -> Bool {
        if (!_keys.contains(value.identifier)) {
            _values.insert(value)
            _keys.insert(value.identifier)
            _valuesForKeys[value.identifier] = value
            return true
        }
        return false
    }
    
    public mutating func update(value: Value) -> Value? {
        let previousValue = _valuesForKeys[value.identifier]
        if let previousValue = previousValue {
            _values.remove(previousValue)
            _keys.remove(previousValue.identifier)
            _valuesForKeys.removeValueForKey(previousValue.identifier)
        }
        insert(value)
        return previousValue
    }
    
    public mutating func remove(value: Value) -> Value? {
        return removeValueForKey(value.identifier);
    }
    
    public mutating func removeAtIndex(index: SetIndex<Value>) {
        let value = self[index]
        remove(value)
    }
    
    public mutating func removeValueForKey(key: Key) -> Value? {
        let removedValue = _valuesForKeys.removeValueForKey(key)
        if let removedValue = removedValue {
            _values.remove(removedValue)
            _keys.remove(removedValue.identifier)
        }
        return removedValue
    }
    
    public mutating func removeAll(keepCapacity: Bool = false) {
        _values.removeAll(keepCapacity: keepCapacity)
        _keys.removeAll(keepCapacity: keepCapacity)
        _valuesForKeys.removeAll(keepCapacity: keepCapacity)
    }
    
    public mutating func removeFirst() -> Value {
        let value = _values.removeFirst()
        _keys.remove(value.identifier)
        _valuesForKeys.removeValueForKey(value.identifier)
        return value
    }
    
    public var count: Int {
        return _values.count
    }
    
    public var first: Value? {
        return _values.first
    }
    
    public var isEmpty: Bool {
        return _values.isEmpty
    }
    
    func isSubsetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keys.isSubsetOf(sequence)
    }
    
    func isSubsetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isSubsetOf(map(sequence, { $0.identifier }))
    }
    
    func isStrictSubsetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keys.isStrictSubsetOf(sequence)
    }
    
    func isStrictSubsetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isStrictSubsetOf(map(sequence, { $0.identifier }))
    }
    
    func isSupersetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keys.isSupersetOf(sequence)
    }
    
    func isSupersetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isSupersetOf(map(sequence, { $0.identifier }))
    }
    
    func isStrictSupersetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keys.isStrictSupersetOf(sequence)
    }
    
    func isStrictSupersetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isStrictSupersetOf(map(sequence, { $0.identifier }))
    }
    
    func isDisjointWith<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keys.isDisjointWith(sequence)
    }
    
    func isDisjointWith<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return isDisjointWith(map(sequence, { $0.identifier }))
    }
    
    
}

extension KeyedSet : Printable, DebugPrintable {
    
    public var description: String {
        return "Keys: \(_keys.description)\n" +
        "Values: \(_values.description)\n" +
        "Values for keys: \(_valuesForKeys.description)"
    }
    
    public var debugDescription: String {
        return "Keys: \(_keys.debugDescription)\n" +
            "Values: \(_values.debugDescription)\n" +
        "Values for keys: \(_valuesForKeys.debugDescription)"
    }
}

extension KeyedSet: ArrayLiteralConvertible {
    public init(arrayLiteral elements: Value...) {
        self.init(elements)
    }
}

extension KeyedSet: Hashable {
    public var hashValue: Int {
        return _values.hashValue
    }
}

public func ==<Key, Value>(lhs: KeyedSet<Key, Value>, rhs: KeyedSet<Key, Value>) -> Bool {
    return lhs._values == rhs._values
}