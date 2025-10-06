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

// import Foundation

public struct OrderedMultiValueErrorInfoGeneric<Key: Hashable, Value>: Sequence {
  public typealias Element = (key: Key, value: ValueWrapper)
  public typealias ValueWrapper = ValueWithCollisionWrapper<Value, CollisionSource>
  public typealias CollisionSource = StringBasedCollisionSource
  
  internal private(set) var _storage: OrderedMultipleValuesForKeyStorage<Key, Value, CollisionSource>
  
  public init() {
    _storage = OrderedMultipleValuesForKeyStorage()
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
                                                 omitEqualValue omitIfEqual: Bool,
                                                 collisionSource: @autoclosure () -> CollisionSource) {
    if omitIfEqual {
      if let currentValues = _storage.allValuesSlice(forKey: key) {
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
    } else {
      _storage.append(key: key, value: newValue, collisionSource: collisionSource())
    }
  }
  
  public mutating func appendResolvingCollisions(_ newElement: (Key, Value),
                                                 omitEqualValue omitIfEqual: Bool,
                                                 collisionSource: @autoclosure () -> CollisionSource) {
    appendResolvingCollisions(key: newElement.0,
                              value: newElement.1,
                              omitEqualValue: omitIfEqual,
                              collisionSource: collisionSource())
  }
}

extension OrderedMultiValueErrorInfoGeneric {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _storage.removeAll(keepingCapacity: keepCapacity)
  }
}

extension OrderedMultiValueErrorInfoGeneric {
  public mutating func mergeWith(other _: Self,
                                 omitEqualValues _: Bool,
                                 mergeOrigin _: @autoclosure () -> CollisionSource.MergeOrigin = .fileLine()) {
    // use update(value:, forKey:) if it is fster than checking hasValue() + append
  }
}
