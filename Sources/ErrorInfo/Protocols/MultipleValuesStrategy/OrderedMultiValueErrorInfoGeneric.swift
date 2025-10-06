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
  public typealias Element = (key: Key, value: Value)
  private typealias ValueWrapper = ValueWithCollisionWrapper<Value, CollisionSource>
  public typealias CollisionSource = StringBasedCollisionSource
  
  private var _storage: OrderedMultipleValuesForKeyStorage<Key, Value, CollisionSource>
  
  public init() {
    _storage = OrderedMultipleValuesForKeyStorage()
  }
  
  public func makeIterator() -> some IteratorProtocol<Element> {
    var sourceIterator = _storage.makeIterator()
    return AnyIterator {
      if let (key, valueWrapper) = sourceIterator.next() {
        (key, valueWrapper.value)
      } else {
        nil
      }
    }
  }
  
  func keyValuesView(shouldOmitEqualValue _: Bool) {}
}

// MARK: - Mutation Methods

extension OrderedMultiValueErrorInfoGeneric {
  public mutating func appendResolvingCollisions(key: Key,
                                                 value newValue: Value,
                                                 omitEqualValue omitIfEqual: Bool,
                                                 collisionSource: @autoclosure () -> CollisionSource) {
    if omitIfEqual {
      if let currentValues = _storage.allValues(forKey: key) {
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
  
  public mutating func mergeWith(other _: Self,
                                 omitEqualValues omitIfEqual: Bool,
                                 mergeOrigin: @autoclosure () -> CollisionSource.MergeOrigin = .fileLine()) {
    // use update(value:, forKey:) if it is fster than checking hasValue() + append
  }
}

// extension OrderedMultiValueErrorInfoGeneric where Key: RangeReplaceableCollection {
//  public mutating func addKeyPrefix(_ keyPrefix: Key) {
//    _storage = ErrorInfoDictFuncs.addKeyPrefix(keyPrefix, toKeysOf: _storage)
//  }
// }

// MARK: - Storage

// MARK: - Protocol Conformances

extension OrderedMultiValueErrorInfoGeneric: Sendable where Key: Sendable, Value: Sendable {}
