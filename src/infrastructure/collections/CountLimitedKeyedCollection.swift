//
//  CountLimitedKeyedCollection.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 5/26/15.
//
//

import Foundation

public final class CountLimitedKeyedCollection<Key: Hashable, Value where Value: UniquelyIdentifiable, Value.Identifier == Key> :
    CollectionType {
    
    public typealias Index = KeyedCollection<Key, Value>.Index
    public typealias Generator = KeyedCollection<Key, Value>.Generator
    
    // MARK: ivars
    
    private var _keyedCollection : KeyedCollection<Key, Value>
    private var _accessTrackingQueue: UniquedQueue<Key>
    
    private let _elementsEvictedObserverSet = ObserverSet<KeyedCollection<Key, Value>>();
    
    // MARK: initializers
    
    public init(minimumCapacity: Int) {
        _keyedCollection = KeyedCollection(minimumCapacity: minimumCapacity)
        _accessTrackingQueue = UniquedQueue(minimumCapacity: minimumCapacity)
    }
    
    public convenience init() {
        self.init(minimumCapacity: 0)
    }
    
    public convenience init<S : SequenceType where S.Generator.Element == Value>(_ sequence: S) {
        self.init()
        _keyedCollection.unionInPlace(sequence, updateExisting: true)
        _accessTrackingQueue.pushBack(sequence.map({ $0.identifier }))
    }
    
    // MARK: CollectionType
    
    public var startIndex: Index {
        return _keyedCollection.startIndex
    }
    
    public var endIndex: Index {
        return _keyedCollection.endIndex
    }
    
    public func generate() -> Generator {
        return _keyedCollection.generate()
    }
    
    public subscript (position: Index) -> (Key, Value) {
        let pair = _keyedCollection[position]
        _accessTrackingQueue.pushBack(pair.0)
        return pair
    }
    
    // MARK: indexes
    
    public func indexForKey(key: Key) -> Index? {
        return _keyedCollection.indexForKey(key)
    }
    
    public func removeAtIndex(index: Index) {
        let pair = _keyedCollection[index]
        _accessTrackingQueue.subtractInPlace(CollectionOfOne(pair.0))
        _keyedCollection.removeAtIndex(index)
    }
    
    // MARK: public
    
    public var limit : Int? {
        didSet {
            evictElementsIfNeeded()
        }
    }
    
    public func addElementsEvictedObserverWithHandler(handler: (evictedElements: KeyedCollection<Key, Value>) -> ()) -> Any {
        return _elementsEvictedObserverSet.add(handler)
    }
    
    public func removeElementsEvictedObserver(observer: Any) {
        if let observerSetEntry = observer as? ObserverSetEntry<KeyedCollection<Key, Value>> {
            _elementsEvictedObserverSet.remove(observerSetEntry)
        }
    }
    
    public var values: LazyForwardCollection<MapCollection<[Key : Value], Value>> {
        return _keyedCollection.values;
    }
    
    public subscript (key: Key) -> Value? {
        _accessTrackingQueue.pushBack(key)
        return _keyedCollection[key]
    }
    
    public func contains(value: Value) -> Bool {
        return _keyedCollection.contains(value)
    }
    
    public func tryInsert(value: Value) -> Bool {
        if (_keyedCollection.tryInsert(value)) {
            _accessTrackingQueue.pushBack(value.identifier)
            evictElementsIfNeeded()
            return true
        }
        return false
    }
    
    public func update(value: Value) -> Value? {
        _accessTrackingQueue.pushBack(value.identifier)
        let oldValue = _keyedCollection.update(value)
        if oldValue == nil {
            evictElementsIfNeeded()
        }
        return oldValue
    }
    
    public func remove(value: Value) -> Value? {
        _accessTrackingQueue.remove(value.identifier)
        return _keyedCollection.remove(value)
    }
    
    public func removeValueForKey(key: Key) -> Value? {
        _accessTrackingQueue.remove(key)
        return _keyedCollection.removeValueForKey(key)
    }
    
    public func removeAll(keepCapacity: Bool = false) {
        _keyedCollection.removeAll(keepCapacity)
        _accessTrackingQueue.removeAll(keepCapacity)
    }
    
    public var count: Int {
        return _keyedCollection.count
    }
    
    public var isEmpty: Bool {
        return _keyedCollection.isEmpty
    }
    
    // MARK: set operations
    
    public func isSubsetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keyedCollection.isSubsetOf(sequence)
    }
    
    public func isSubsetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return _keyedCollection.isSubsetOf(sequence)
    }
    
    public func isStrictSubsetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keyedCollection.isStrictSubsetOf(sequence)
    }
    
    public func isStrictSubsetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return _keyedCollection.isStrictSubsetOf(sequence)
    }
    
    public func isSupersetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keyedCollection.isSupersetOf(sequence)
    }
    
    public func isSupersetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return _keyedCollection.isSupersetOf(sequence)
    }
    
    public func isStrictSupersetOf<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keyedCollection.isStrictSupersetOf(sequence)
    }
    
    public func isStrictSupersetOf<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return _keyedCollection.isStrictSupersetOf(sequence)
    }
    
    public func isDisjointWith<S : SequenceType where S.Generator.Element == Key>(sequence: S) -> Bool {
        return _keyedCollection.isDisjointWith(sequence)
    }
    
    public func isDisjointWith<S : SequenceType where S.Generator.Element == Value>(sequence: S) -> Bool {
        return _keyedCollection.isDisjointWith(sequence)
    }
    
    // MARK:
    
    public func unionInPlace<S : SequenceType where S.Generator.Element == Value>(sequence: S, updateExisting: Bool = false) {
        _keyedCollection.unionInPlace(sequence, updateExisting: updateExisting)
        _accessTrackingQueue.pushBack(sequence.map({ $0.identifier }))
        evictElementsIfNeeded()
    }
    
    public func subtractInPlace<S : SequenceType where S.Generator.Element == Value>(sequence: S) {
        _keyedCollection.subtractInPlace(sequence)
        _accessTrackingQueue.subtractInPlace(sequence.map({ $0.identifier }))
    }
    
    public func intersectInPlace<S : SequenceType where S.Generator.Element == Value>(sequence: S, updateExisting: Bool = false) {
        _keyedCollection.intersectInPlace(sequence, updateExisting: updateExisting)
        _accessTrackingQueue.removeAll(true)
        _accessTrackingQueue.pushBack(_keyedCollection.map({ $0.0 }))
    }
    
    public func exclusiveOrInPlace<S : SequenceType where S.Generator.Element == Value>(sequence: S) {
        _keyedCollection.exclusiveOrInPlace(sequence)
        _accessTrackingQueue.removeAll(true)
        _accessTrackingQueue.pushBack(_keyedCollection.map({ $0.0 }))
        evictElementsIfNeeded()
    }
    
    // Mark: private
    
    private func evictElementsIfNeeded() {
        if let limit = limit {
            let numberOfElementsToRemove = count - limit
            if numberOfElementsToRemove > 0 {
                let removedKeys = _accessTrackingQueue.popFront(numberOfElementsToRemove)
                _keyedCollection.subtractInPlace(removedKeys)
            }
        }
    }
}

extension CountLimitedKeyedCollection : CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return "Keyed collection: \(_keyedCollection.description)\n" +
        "Access tracking queue: \(_accessTrackingQueue.description)"
    }
    
    public var debugDescription: String {
        return "Keyed collection: \(_keyedCollection.debugDescription)\n" +
        "Access tracking queue: \(_accessTrackingQueue.debugDescription)"
    }
}

extension CountLimitedKeyedCollection: ArrayLiteralConvertible {
    public typealias Element = Value
    
    public convenience init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension CountLimitedKeyedCollection: Hashable {
    public var hashValue: Int {
        return _keyedCollection.hashValue
    }
}

public func ==<Key, Value>(lhs: CountLimitedKeyedCollection<Key, Value>, rhs: CountLimitedKeyedCollection<Key, Value>) -> Bool {
    return lhs._keyedCollection == rhs._keyedCollection
}
