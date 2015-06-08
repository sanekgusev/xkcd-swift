//
//  UniquedQueue.swift
//  xkcd-swift
//
//  Created by Aleksandr Gusev on 5/29/15.
//
//

import Foundation

public struct UniquedQueue <T where T: Hashable> : CollectionType {
    
    public typealias Index = Int
    
    // MARK: ivars
    
    private var _set: Set<T>
    private var _array: [T]
    
    // MARK: initializers
    
    public init(minimumCapacity: Int) {
        _set = Set<T>(minimumCapacity: minimumCapacity)
        _array = [T]()
    }
    
    public init() {
        self.init(minimumCapacity: 0)
    }
    
    public init<S : SequenceType where S.Generator.Element == T>(_ s: S) {
        self.init()
        pushBack(s)
    }
    
    // MARK: CollectionType
    
    public var startIndex: Index {
        return _array.startIndex
    }
    
    public var endIndex: Index {
        return _array.endIndex
    }
    
    public func generate() -> IndexingGenerator<UniquedQueue> {
        return IndexingGenerator(self)
    }
    
    public subscript (position: Index) -> T {
        return _array[position]
    }
    
    // MARK: public
    
    public mutating func pushBack<S : SequenceType where S.Generator.Element == T>(sequence: S) {
        for element in sequence {
            _array.append(element)
            if _set.contains(element) {
                if let firstIndex = find(_array, element) {
                    _array.removeAtIndex(firstIndex)
                }
            }
            else {
                _set.insert(element)
            }
        }
    }
    
    public mutating func pushBack(element: T) {
        pushBack(CollectionOfOne(element))
    }
    
    public mutating func popFront(count: Int) -> [T] {
        if !isEmpty {
            var counter: Int = 0
            let poppedElements = split(_array,
                maxSplit: 1,
                allowEmptySlices: true,
                isSeparator: { element in
                    return ++counter > count
            })[0]
            _set.subtractInPlace(poppedElements)
            _array.removeRange(Range(start: 0, end: poppedElements.count))
            return [T](poppedElements)
        }
        return []
    }
    
    public mutating func popFront() -> T? {
        return popFront(1).first
    }
    
    public mutating func subtractInPlace<S : SequenceType where S.Generator.Element == T>(sequence: S) {
        _set.subtractInPlace(sequence)
        _array = _array.filter { element in
            return self._set.contains(element)
        }
    }
    
    public mutating func remove(element: T) {
        subtractInPlace(CollectionOfOne(element))
    }
    
    public var count : Int {
        return _array.count
    }
    
    public var isEmpty : Bool {
        return _array.isEmpty
    }
    
    public var first: T? {
        return _array.first
    }
    
    public var last: T? {
        return _array.last
    }
    
    public mutating func removeAll(keepCapacity: Bool = false) {
        _array.removeAll(keepCapacity: keepCapacity)
        _set.removeAll(keepCapacity: keepCapacity)
    }
}

extension UniquedQueue : ArrayLiteralConvertible {
    typealias Element = T
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }
}

extension UniquedQueue : Hashable {
    public var hashValue: Int {
        return _set.hashValue
    }
}

public func ==<T>(lhs: UniquedQueue<T>, rhs: UniquedQueue<T>) -> Bool {
    return lhs._array == rhs._array
}

extension UniquedQueue : Printable, DebugPrintable {
    
    public var description: String {
        return "Set: \(_set.description)\n" +
        "Array: \(_array.description)"
    }
    
    public var debugDescription: String {
        return "Set: \(_set.debugDescription)\n" +
        "Array: \(_array.debugDescription)"
    }
}