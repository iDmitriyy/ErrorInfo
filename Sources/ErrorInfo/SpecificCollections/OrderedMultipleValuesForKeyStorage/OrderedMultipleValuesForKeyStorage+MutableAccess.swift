//
//  OrderedMultipleValuesForKeyStorage+MutableAccess.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/10/2025.
//

extension OrderedMultipleValuesForKeyStorage {
  // FIXME: eliminate COW for underlying dicts of Variant when mutating
  
  // References:
  // - https://github.com/swiftlang/swift-evolution/blob/main/proposals/0432-noncopyable-switch.md
  //   Future directions: inout pattern matches
  // - https://forums.swift.org/t/in-place-mutation-of-an-enum-associated-value/11747/5
  @usableFromInline internal struct _Variant {
    @usableFromInline internal var _variant: Variant!
    
    @inlinable @inline(__always)
    internal init(_ variant: Variant) {
      _variant = variant
    }
    
    @inlinable @inline(__always)
    internal mutating func mutateUnderlying(singleValueForKey mutateLeft: (inout SingleValueForKeyDict) -> Void,
                                            multiValueForKey mutateRight: (inout MultiValueForKeyDict) -> Void) {
      var singleValueForKeyDict: SingleValueForKeyDict!
      var multiValueForKeyDict: MultiValueForKeyDict!
      // keep only one strong reference to underlying dict for CoW prevention
      switch _variant! {
      case .left(let instance): singleValueForKeyDict = instance
      case .right(let instance): multiValueForKeyDict = instance
      }
      _variant = nil // destroy _variant enum wrapper with strong references to underlying dict
      
      if singleValueForKeyDict != nil {
        mutateLeft(&singleValueForKeyDict)
        _variant = .left(singleValueForKeyDict)
        return
      }
      
      mutateRight(&multiValueForKeyDict)
      _variant = .right(multiValueForKeyDict)
    }
    
    @inlinable @inline(__always)
    internal mutating func withResultMutateUnderlying<R>(singleValueForKey mutateLeft: (inout SingleValueForKeyDict) -> R,
                                                         multiValueForKey mutateRight: (inout MultiValueForKeyDict) -> R) -> R {
      // --- copy-paste from `mutateUnderlying`
      var singleValueForKeyDict: SingleValueForKeyDict!
      var multiValueForKeyDict: MultiValueForKeyDict!
      // keep only one strong reference to underlying dict for CoW prevention
      switch _variant! {
      case .left(let instance): singleValueForKeyDict = instance
      case .right(let instance): multiValueForKeyDict = instance
      }
      _variant = nil // destroy _variant enum wrapper with strong references to underlying dict
      // --- end copy-paste
      // Improvement: remove implicitly unwrapped optional when switch with inout access to associated vaalues
      // will be introduced.
      if singleValueForKeyDict != nil {
        let result = mutateLeft(&singleValueForKeyDict)
        _variant = .left(singleValueForKeyDict)
        return result
      }
      
      let result = mutateRight(&multiValueForKeyDict)
      _variant = .right(multiValueForKeyDict)
      return result
    }
    
    /// Replaces `SingleValueForKeyDict` by `MultiValueForKeyDict` when first collision happens
    @inlinable @inline(__always)
    internal mutating func appendIfNotPresent(
      key newKey: Key,
      value newValue: Value,
      writeProvenance: @autoclosure () -> WriteProvenance,
      rejectWhenExistingMatches decideToReject: (_ existing: AnnotatedValue) -> Bool,
    ) {
      // Improvement:
      // - implement geometric growth strategy, OrderedCollections has no `capacity` property now
      // - hasValue(forKey:) – which faster
      // + multiValueForKeyDict.append(contentsOf: singleValueForKeyDict)
      // - optimize writeProvenance()
      // - https://forums.swift.org/t/in-place-mutation-of-an-enum-associated-value/11747/15
      
      // --- copy-paste from `mutateUnderlying`
      var singleValueForKeyDict: SingleValueForKeyDict!
      var multiValueForKeyDict: MultiValueForKeyDict!
      // keep only one strong reference to underlying dict for CoW prevention
      switch _variant! {
      case .left(let instance): singleValueForKeyDict = instance
      case .right(let instance): multiValueForKeyDict = instance
      }
      _variant = nil // destroy _variant enum wrapper with strong references to underlying dict
      // --- end copy-paste

      if singleValueForKeyDict != nil {
        if let existing = singleValueForKeyDict[newKey] {
          if decideToReject(.value(existing)) {
            _variant = .left(singleValueForKeyDict)
            return
          }
          var multiValueDict = OrderedMultiValueDictionary
            .migratedFrom(singleValueForKeyDictionary: singleValueForKeyDict)
          
          multiValueDict.append(key: newKey,
                                value: .collidedValue(newValue, collisionSource: writeProvenance()))
          _variant = .right(multiValueDict)
        } else {
          singleValueForKeyDict[newKey] = newValue
          _variant = .left(singleValueForKeyDict)
        }
        return
      }

      if let indexSet = multiValueForKeyDict._keyToEntryIndices[newKey] {
        switch indexSet._variant {
        case .left(let index):
          if decideToReject(multiValueForKeyDict._entries[index].value) {
            _variant = .right(multiValueForKeyDict)
            return
          }

        case .right(let indices):
          for index in indices {
            if decideToReject(multiValueForKeyDict._entries[index].value) {
              _variant = .right(multiValueForKeyDict)
              return
            }
          }
        }

        multiValueForKeyDict.append(key: newKey,
                                    value: .collidedValue(newValue, collisionSource: writeProvenance()))
      } else {
        multiValueForKeyDict.append(key: newKey, value: .value(newValue))
      }

      _variant = .right(multiValueForKeyDict)
    }
    
    /// Replaces `SingleValueForKeyDict` by `MultiValueForKeyDict` when first collision happens
    @inlinable @inline(__always)
    internal mutating func appendUnconditionally(
      key newKey: Key,
      value newValue: Value,
      writeProvenance: @autoclosure () -> WriteProvenance,
    ) {
      // --- copy-paste from `mutateUnderlying`
      var singleValueForKeyDict: SingleValueForKeyDict!
      var multiValueForKeyDict: MultiValueForKeyDict!
      // keep only one strong reference to underlying dict for CoW prevention
      switch _variant! {
      case .left(let instance): singleValueForKeyDict = instance
      case .right(let instance): multiValueForKeyDict = instance
      }
      _variant = nil // destroy _variant enum wrapper with strong references to underlying dict
      // --- end copy-paste

      if singleValueForKeyDict != nil {
        if singleValueForKeyDict.hasValue(forKey: newKey) {
          var multiValueDict = OrderedMultiValueDictionary
            .migratedFrom(singleValueForKeyDictionary: singleValueForKeyDict)
          
          multiValueDict.append(key: newKey,
                                value: .collidedValue(newValue, collisionSource: writeProvenance()))
          _variant = .right(multiValueDict)
        } else {
          singleValueForKeyDict[newKey] = newValue
          _variant = .left(singleValueForKeyDict)
        }
        return
      }

      let annotated: AnnotatedValue = if multiValueForKeyDict.hasValue(forKey: newKey) {
        .collidedValue(newValue, collisionSource: writeProvenance())
      } else {
        .value(newValue)
      }
      multiValueForKeyDict.append(key: newKey, value: annotated)
      _variant = .right(multiValueForKeyDict)
    }
  }
}

extension OrderedMultipleValuesForKeyStorage._Variant: Sendable where Key: Sendable, Value: Sendable, WriteProvenance: Sendable {}
