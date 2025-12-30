//
//  OrderedMultipleValuesForKeyStorage.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/10/2025.
//

/// Purpose: reducing the overhead which `OrderedMultiValueDictionary` has.
/// Used by error info types to efficiently manage key-value pairs, typically unique but capable
/// to store multiple values for key.
///
/// ### Storage Mechanism:
/// - Uses an `OrderedDictionary` for single-value-for-key storage, ensuring fast lookup and insertion.
/// - Transitions to an `OrderedMultiValueDictionary` when first collision occur (multiple values for the same key).
///
/// While all key-values are unique (and stored in `OrderedDictionary`), there is no need to allocate space for
/// `CollisionAnnotatedRecord` – values can be stored as is.
///
/// ### Efficiency:
/// - Avoids extra memory overhead when there are no collisions, as no additional space for collisions and values indices is required.
/// - Introduces more complex `OrderedMultiValueDictionary` only when necessary, reducing memory usage and improving performance
/// when keys are unique.
@usableFromInline internal struct OrderedMultipleValuesForKeyStorage<Key: Hashable, Value> {
  @inlinable
  @inline(__always)
  internal var _variant: Variant { _mutableVariant._variant }
  
  // FIXME: private set
  @usableFromInline internal var _mutableVariant: _Variant
  
  internal init() {
    _mutableVariant = _Variant(.left(OrderedDictionary()))
  }
  
  internal init(minimumCapacity: Int) {
    _mutableVariant = _Variant(.left(OrderedDictionary(minimumCapacity: minimumCapacity)))
  }
  
  private init(_variant: _Variant) {
    _mutableVariant = _variant
  }
  
  @inlinable @inline(__always)
  internal mutating func reserveCapacity(_ minimumCapacity: Int) {
    _mutableVariant.mutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      singleValueForKeyDict.reserveCapacity(minimumCapacity)
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.reserveCapacity(minimumCapacity)
    })
  }
}

extension OrderedMultipleValuesForKeyStorage: Sendable where Key: Sendable, Value: Sendable, WriteProvenance: Sendable {}

// MARK: All Values For Key

extension OrderedMultipleValuesForKeyStorage {
  // TODO: performance test allValues vs allValuesSlice
//  internal func allValuesSlice(forKey key: Key) -> (some Sequence<TaggedValue>)? { // & ~Escapable
//    ValuesForKeySlice(_variant: _variant, key: key)
//  }
  
  internal func iterateAllValues(forKey key: Key, _ iteration: (AnnotatedValue) -> Void) {
    switch _variant {
    case .left(let singleValueForKeyDict):
      if let valueForKey = singleValueForKeyDict[key] {
        iteration(AnnotatedValue.value(valueForKey))
      }
    case .right(let multiValueForKeyDict):
      multiValueForKeyDict.iterateAllValues(forKey: key, iteration)
    }
  }
  
  internal func allValues(forKey key: Key) -> ValuesForKey<AnnotatedValue>? {
    switch _variant {
    case .left(let singleValueForKeyDict):
      if let valueForKey = singleValueForKeyDict[key] {
        ValuesForKey(element: AnnotatedValue.value(valueForKey))
      } else {
        nil
      }
    case .right(let multiValueForKeyDict):
      multiValueForKeyDict.allValues(forKey: key)
    }
  }
  
  @discardableResult
  internal mutating func removeAllValues(forKey key: Key) -> ValuesForKey<AnnotatedValue>? {
    _mutableVariant.withResultMutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      if let oldValue = singleValueForKeyDict.removeValue(forKey: key) {
        ValuesForKey(element: AnnotatedValue.value(oldValue))
      } else {
        nil
      }
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.removeAllValues(forKey: key)
    })
  }
  
  internal mutating func removeAllWhere(_ predicate: (_ key: Key, _ taggedValue: AnnotatedValue) -> Bool) {
    _mutableVariant.mutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      singleValueForKeyDict.removeAll(where: { predicate($0.key, AnnotatedValue.value($0.value)) })
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.removeAll(where: predicate)
    })
  }
  
  internal mutating func filter(_ isIncluded: (_ key: Key, _ taggedValue: AnnotatedValue) -> Bool) -> Self {
    switch _variant {
    case .left(let singleValueForKeyDict):
      let filtered = singleValueForKeyDict.filter { isIncluded($0.key, AnnotatedValue.value($0.value)) }
      return Self(_variant: _Variant(.left(filtered)))

    case .right(let multiValueForKeyDict):
      let filtered: MultiValueForKeyDict = multiValueForKeyDict.filter(isIncluded)
      return Self(_variant: _Variant(.right(filtered)))
    }
  }
}

// MARK: Append KeyValue

extension OrderedMultipleValuesForKeyStorage {
  @usableFromInline
  internal mutating func appendIfNotPresent(key newKey: Key,
                                            value newValue: Value,
                                            writeProvenance: @autoclosure () -> WriteProvenance,
                                            andRejectWhenExistingMatches decideToReject: (_ existing: AnnotatedValue) -> Bool) {
    _mutableVariant.appendIfNotPresent(key: newKey,
                                       value: newValue,
                                       writeProvenance: writeProvenance(),
                                       rejectWhenExistingMatches: decideToReject)
  }
  
  @usableFromInline
  internal mutating func appendUnconditionally(key newKey: Key,
                                               value newValue: Value,
                                               writeProvenance: @autoclosure () -> WriteProvenance) {
    _mutableVariant.appendUnconditionally(key: newKey, value: newValue, writeProvenance: writeProvenance())
  }
}

extension OrderedMultipleValuesForKeyStorage {
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool) {
    _mutableVariant.mutateUnderlying(singleValueForKey: { singleValueForKeyDict in
      singleValueForKeyDict.removeAll(keepingCapacity: keepCapacity)
    }, multiValueForKey: { multiValueForKeyDict in
      multiValueForKeyDict.removeAll(keepingCapacity: keepCapacity)
    })
  }
}

// TODO: using of inlining seems reasonable only internally. For public types like ErrorInfo dynamic disptach might be ok
// as it is fast.
