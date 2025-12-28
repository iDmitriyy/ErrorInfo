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
    // FIXME: private set
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
      
      // making only one string reference to underlying dict for COW prevention
      switch _variant! {
      case .left(let instance): singleValueForKeyDict = instance
      case .right(let instance): multiValueForKeyDict = instance
      }
      
      _variant = nil // deallocate _variant enum wrapper with strong references to underlying dict
      
      if singleValueForKeyDict != nil {
        mutateLeft(&singleValueForKeyDict)
        _variant = .left(singleValueForKeyDict)
      } else if multiValueForKeyDict != nil {
        mutateRight(&multiValueForKeyDict)
        _variant = .right(multiValueForKeyDict)
      }
    }
    
    @inlinable @inline(__always)
    internal mutating func withResultMutateUnderlying<R>(singleValueForKey mutateLeft: (inout SingleValueForKeyDict) -> R,
                                                         multiValueForKey mutateRight: (inout MultiValueForKeyDict) -> R) -> R {
      var singleValueForKeyDict: SingleValueForKeyDict!
      var multiValueForKeyDict: MultiValueForKeyDict!
      
      // making only one string reference to underlying dict for COW prevention
      switch _variant! {
      case .left(let instance): singleValueForKeyDict = instance
      case .right(let instance): multiValueForKeyDict = instance
      }
      
      _variant = nil // deallocate _variant enum wrapper with strong references to underlying dict
      
      if singleValueForKeyDict != nil {
        let result = mutateLeft(&singleValueForKeyDict)
        _variant = .left(singleValueForKeyDict)
        return result
      } else if multiValueForKeyDict != nil {
        let result = mutateRight(&multiValueForKeyDict)
        _variant = .right(multiValueForKeyDict)
        return result
      } else {
        fatalError("OrderedMultipleValuesForKeyStorage internal error: empty variant")
      }
    }
    
    /// Replaces `SingleValueForKeyDict` by `MultiValueForKeyDict` when first collision happens
    @inlinable @inline(__always)
    internal mutating func append(key newKey: Key,
                                  value newValue: Value,
                                  writeProvenance: @autoclosure () -> WriteProvenance) {
      // --- copy-paste from `mutateUnderlying`
      var singleValueForKeyDict: SingleValueForKeyDict!
      var multiValueForKeyDict: MultiValueForKeyDict!
      
      // making only one string reference to underlying dict for COW prevention
      switch _variant! {
      case .left(let instance): singleValueForKeyDict = instance
      case .right(let instance): multiValueForKeyDict = instance
      }
      
      _variant = nil // destroy _variant enum wrapper with strong references to underlying dict
      // end copy-paste
      
      if singleValueForKeyDict != nil {
        // TODO: instead of checking `hasValue(forKey:)` use `update()` and check if result != nil
        // measure time which is faster
        if singleValueForKeyDict.hasValue(forKey: newKey) {
          var multiValueForKeyDict = MultiValueForKeyDict()
          for (currentKey, currentValue) in singleValueForKeyDict {
            multiValueForKeyDict.append(key: currentKey, value: TaggedValue.value(currentValue))
          }
          let newValueWrapped = TaggedValue.collidedValue(newValue, collisionSource: writeProvenance())
          multiValueForKeyDict.append(key: newKey, value: newValueWrapped)
          _variant = .right(multiValueForKeyDict)
        } else {
          singleValueForKeyDict[newKey] = newValue
          _variant = .left(singleValueForKeyDict)
        }
      } else if multiValueForKeyDict != nil {
        let newValueWrapped: TaggedValue = if multiValueForKeyDict.hasValue(forKey: newKey) {
          .collidedValue(newValue, collisionSource: writeProvenance())
        } else {
          .value(newValue)
        }
        multiValueForKeyDict.append(key: newKey, value: newValueWrapped)
        _variant = .right(multiValueForKeyDict)
      }
    }
    
    @inlinable @inline(__always)
    internal mutating func appendIfNotPresent(
      key newKey: Key,
      value newValue: Value,
      writeProvenance: @autoclosure () -> WriteProvenance,
      rejectWhenExistingMatches decideToReject: (_ existing: TaggedValue) -> Bool,
    ) {
//      var singleValueForKeyDict: SingleValueForKeyDict!
//      var multiValueForKeyDict: MultiValueForKeyDict!
//
//      switch _variant! {
//      case .left(let instance): singleValueForKeyDict = instance
//      case .right(let instance): multiValueForKeyDict = instance
//      }

      // Improvement:
      // - remove implicitly unwrapped optionals (might be optimized by compiler)
      // - separate closoure for first collision
      // - pass borrowing value
      // - hasValue(forKey:) – which faster
      // + multiValueForKeyDict.append(contentsOf: singleValueForKeyDict)
      // - inlining
      // - optimize writeProvenance()
      
//      _variant = nil

     
      switch _variant! {
      case .left(var singleValueForKeyDict):
        if let existing = singleValueForKeyDict[newKey] {
          if decideToReject(.value(existing)) {
            return
          }
                    
          var multiValueForKeyDict = MultiValueForKeyDict(minimumCapacity: singleValueForKeyDict.count + 1)
          for index in singleValueForKeyDict.indices {
            let (key, value) = singleValueForKeyDict[index]
            multiValueForKeyDict.append(key: key, value: .value(value))
          }
          
          multiValueForKeyDict.append(key: newKey, value: .collidedValue(newValue, collisionSource: writeProvenance()))
          _variant = .right(multiValueForKeyDict)
        } else {
          singleValueForKeyDict[newKey] = newValue
          _variant = .left(singleValueForKeyDict)
        }
        
      case .right(var multiValueForKeyDict):
        if let indexSet = multiValueForKeyDict._keyToEntryIndices[newKey] {
          switch indexSet._variant {
          case .left(let index):
            if decideToReject(multiValueForKeyDict._entries[index].value) {
              return
            }

          case .right(let indices):
            for index in indices {
              if decideToReject(multiValueForKeyDict._entries[index].value) {
                return
              }
            }
          }

          multiValueForKeyDict.append(key: newKey, value: .collidedValue(newValue, collisionSource: writeProvenance()))
        } else {
          multiValueForKeyDict.append(key: newKey, value: .value(newValue))
        }

        _variant = .right(multiValueForKeyDict)
      }
    }
    
    @inlinable @inline(__always)
    internal mutating func appendUnconditionally(
      key newKey: Key,
      value newValue: Value,
      writeProvenance: @autoclosure () -> WriteProvenance,
    ) {
      switch _variant! {
      case .left(var singleValueForKeyDict):
        if singleValueForKeyDict.hasValue(forKey: newKey) {
          var multiValueForKeyDict = MultiValueForKeyDict(minimumCapacity: singleValueForKeyDict.count + 1)
          for index in singleValueForKeyDict.indices {
            let (key, value) = singleValueForKeyDict[index]
            multiValueForKeyDict.append(key: key, value: .value(value))
          }
          
          multiValueForKeyDict.append(key: newKey, value: .collidedValue(newValue, collisionSource: writeProvenance()))
          _variant = .right(multiValueForKeyDict)
        } else {
          singleValueForKeyDict[newKey] = newValue
          _variant = .left(singleValueForKeyDict)
        }
      case .right(var multiValueForKeyDict):
        let annotated: TaggedValue = if multiValueForKeyDict.hasValue(forKey: newKey) {
          .collidedValue(newValue, collisionSource: writeProvenance())
        } else {
          .value(newValue)
        }
        multiValueForKeyDict.append(key: newKey, value: annotated)
        _variant = .right(multiValueForKeyDict)
      }
    }
  }
}

extension OrderedMultipleValuesForKeyStorage._Variant: Sendable where Key: Sendable, Value: Sendable, WriteProvenance: Sendable {}
