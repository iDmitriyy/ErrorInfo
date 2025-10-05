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
  
  // Improvement:
  // Typically there will be one value for each key, so OrderedDictionary is enough for most situations.
  // OrderedMultiValueDictionary is needed when first collision happens.
  // All overhead which OrderedMultiValueDictionary has can be eliminated untill first collision happens.
  // _storage: Either<OrderedDictionary<Key, Value>, OrderedMultiValueDictionary<Key, ValueWrapper>>
  private var _storage: OrderedMultiValueDictionary<Key, ValueWrapper>
  
  public init() {
    _storage = OrderedMultiValueDictionary<Key, ValueWrapper>()
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
    if let currentValues = _storage.allValuesView(forKey: key) {
      lazy var isEqualToCurrent = currentValues.contains(where: { currentValue in
        ErrorInfoFuncs.isApproximatelyEqualAny(currentValue.value, newValue)
      })
      
      // if both `isEqualToCurrent` and `omitIfEqual` are true then value must not be added. Otherwise add it.
      if omitIfEqual, isEqualToCurrent {
        return
      } else {
        // FIXME: collisionSource
        _storage.append(key: key, value: .collidedValue(newValue, collisionSource: collisionSource()))
      }
    } else {
      _storage.append(key: key, value: .value(newValue))
    }
  }
  
  public mutating func mergeWith(other _: Self) {}
}

// extension OrderedMultiValueErrorInfoGeneric where Key: RangeReplaceableCollection {
//  public mutating func addKeyPrefix(_ keyPrefix: Key) {
//    _storage = ErrorInfoDictFuncs.addKeyPrefix(keyPrefix, toKeysOf: _storage)
//  }
// }

// MARK: - Storage

// MARK: - Protocol Conformances

extension OrderedMultiValueErrorInfoGeneric: Sendable where Key: Sendable, Value: Sendable {}

// MARK: - Value + Collision Wrapper

internal struct ValueWithCollisionWrapper<Value, CollSource> {
  internal let value: Value
  internal let collisionSource: CollSource?
  
  private init(value: Value, collisionSource: CollSource?) {
    self.value = value
    self.collisionSource = collisionSource
  }
  
  internal static func value(_ value: Value) -> Self { Self(value: value, collisionSource: nil) }
  
  internal static func collidedValue(_ value: Value, collisionSource: CollSource) -> Self {
    Self(value: value, collisionSource: collisionSource)
  }
}

extension ValueWithCollisionWrapper: Sendable where Value: Sendable, CollSource: Sendable {}

// fileprivate enum ValueWithCollisionWrapper<Value, Source> {
//  case value(Value)
//  case collidedValue(Value, collisionSource: CollSource)
//
//  var value: Value {
//    switch self {
//    case .value(let value): value
//    case .collidedValue(let value, _): value
//    }
//  }
// }
