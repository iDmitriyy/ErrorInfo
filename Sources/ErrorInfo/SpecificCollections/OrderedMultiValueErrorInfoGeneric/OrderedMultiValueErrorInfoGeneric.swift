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

public struct OrderedMultiValueErrorInfoGeneric<Key: Hashable, Value: ApproximatelyEquatable>: Sequence {
  public typealias Element = (key: Key, value: TaggedValue)
  public typealias TaggedValue = CollisionTaggedValue<Value, CollisionSource>
  
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
  
  // Improvement: check all usages of `allValues(forKey:)`, replace by slice if needed
  
  public func allValues(forKey key: Key) -> ValuesForKey<TaggedValue>? {
    _storage.allValues(forKey: key)
  }
  
  @discardableResult
  internal mutating func removeAllValues(forKey key: Key) -> ValuesForKey<TaggedValue>? {
    _storage.removeAllValues(forKey: key)
  }
}

// MARK: Append KeyValue

extension OrderedMultiValueErrorInfoGeneric {
  // FIXME: remove @autoclosure
  public mutating func appendResolvingCollisions(key: Key,
                                                 value newValue: Value,
                                                 insertIfEqual: Bool,
                                                 collisionSource: @autoclosure () -> CollisionSource) {
    if insertIfEqual {
      _storage.append(key: key, value: newValue, collisionSource: collisionSource())
    } else {
      if let currentValues = _storage.allValuesSlice(forKey: key) {
        // TBD: perfomace Test: _storage.containsValues(forKey:, where:) might be faster than allValuesSlice(forKey:).contains
        let isEqualToOneOfCurrent = currentValues.contains(where: { currentValue in
          newValue.isApproximatelyEqual(to: currentValue.value)
        })
        
        if isEqualToOneOfCurrent {
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

// MARK: - ApproximatelyEquatable

public protocol ApproximatelyEquatable: ~Copyable {
  static func isApproximatelyEqual(lhs: borrowing Self, rhs: borrowing Self) -> Bool
}

extension ApproximatelyEquatable {
  func isApproximatelyEqual(to other: borrowing Self) -> Bool {
    Self.isApproximatelyEqual(lhs: self, rhs: other)
  }
}
