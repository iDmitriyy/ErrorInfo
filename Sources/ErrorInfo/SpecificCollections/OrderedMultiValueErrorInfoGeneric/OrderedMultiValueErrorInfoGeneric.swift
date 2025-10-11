//
//  OrderedMultiValueErrorInfoGeneric.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 20/09/2025.
//

/*
 TODO:
 Save relative order of apending values. Example:
 info = init(sequence: [(key1, A), (key2, B), (key1, C), (key2, D)]). No matter for which key each value was added, the order
 of values is: A, B, C, D. This order should be during iteration.
 If ordered dictionary with array of values is used then the following order will be during iteration:
 (key1, A), (key1, C), (key2, B), (key2, D)
 which differs from the order values were appended
 */

public struct OrderedMultiValueErrorInfoGeneric<Key: Hashable, Value>: Sequence {
  public typealias Element = (key: Key, value: ValueWrapper)
  public typealias ValueWrapper = ValueWithCollisionWrapper<Value, CollisionSource>
  public typealias CollisionSource = StringBasedCollisionSource
  
  internal private(set) var _storage: OrderedMultipleValuesForKeyStorage<Key, Value, CollisionSource>
  
  public init() {
    _storage = OrderedMultipleValuesForKeyStorage()
  }
  
  public init(minimumCapacity: Int) {
    _storage = OrderedMultipleValuesForKeyStorage(minimumCapacity: minimumCapacity)
  }
}

extension OrderedMultiValueErrorInfoGeneric: Sendable where Key: Sendable, Value: Sendable {}

extension OrderedMultiValueErrorInfoGeneric {
  public func hasValue(forKey key: Key) -> Bool {
    _storage.hasValue(forKey: key)
  }
}

// MARK: All Values For Key

extension OrderedMultiValueErrorInfoGeneric {
  // public func allValuesSlice(forKey key: Key) -> (some Sequence<Value>)? {}
  
  public func allValues(forKey key: Key) -> ValuesForKey<ValueWrapper>? {
    _storage.allValues(forKey: key)
  }
  
  @discardableResult
  internal mutating func removeAllValues(forKey key: Key) -> ValuesForKey<ValueWrapper>? {
    _storage.removeAllValues(forKey: key)
  }
}

// MARK: Append KeyValue

extension OrderedMultiValueErrorInfoGeneric {
  public mutating func appendResolvingCollisions(key: Key,
                                                 value newValue: Value,
                                                 insertIfEqual: Bool,
                                                 collisionSource: @autoclosure () -> CollisionSource) {
    if insertIfEqual {
      _storage.append(key: key, value: newValue, collisionSource: collisionSource())
    } else {
      if let currentValues = _storage.allValuesSlice(forKey: key) {
        // TODO: perfomace Test: containsValues(forKey:, where:) might be faster than allValuesSlice(forKey:)
        let isEqualToCurrent = currentValues.contains(where: { currentValue in
          ErrorInfoFuncs.isApproximatelyEqualAny(currentValue.value, newValue)
        })
        
        if isEqualToCurrent {
          return
        } else {
          _storage.append(key: key, value: newValue, collisionSource: collisionSource())
        }
      } else {
        _storage.append(key: key, value: newValue, collisionSource: collisionSource())
      }
    }
  }
  
  public mutating func appendResolvingCollisions(element: (Key, Value),
                                                 insertIfEqual: Bool,
                                                 collisionSource: @autoclosure () -> CollisionSource) {
    appendResolvingCollisions(key: element.0,
                              value: element.1,
                              insertIfEqual: insertIfEqual,
                              collisionSource: collisionSource())
  }
}

extension OrderedMultiValueErrorInfoGeneric {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _storage.removeAll(keepingCapacity: keepCapacity)
  }
}
