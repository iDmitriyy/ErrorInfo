//
//  OrderedMultipleValuesForKeyStorage+MutableAccess.swift
//  ErrorInfo
//
//  Created by tmp on 05/10/2025.
//

extension OrderedMultipleValuesForKeyStorage {
  // FIXME: eliminate COW for underlying dicts of Variant when mutating
  
  // References:
  // - https://github.com/swiftlang/swift-evolution/blob/main/proposals/0432-noncopyable-switch.md
  //   Future directions: inout pattern matches
  // - https://forums.swift.org/t/in-place-mutation-of-an-enum-associated-value/11747/5
  internal struct _Variant {
    internal private(set) var _variant: Variant!
    
    internal init(_ variant: Variant) {
      _variant = variant
    }
    
    @inlinable
    @inline(__always)
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
    
    /// Replaces `SingleValueForKeyDict` by `MultiValueForKeyDict` when first collision happens
    @inlinable
    @inline(__always)
    internal mutating func append(key newKey: Key,
                                  value newValue: Value,
                                  collisionSourceSpecifier: @autoclosure () -> CollisionSourceSpecifier) {
      // --- copy-paste from `mutateUnderlying`
      var singleValueForKeyDict: SingleValueForKeyDict!
      var multiValueForKeyDict: MultiValueForKeyDict!
      
      // making only one string reference to underlying dict for COW prevention
      switch _variant! {
      case .left(let instance): singleValueForKeyDict = instance
      case .right(let instance): multiValueForKeyDict = instance
      }
      
      _variant = nil // deallocate _variant enum wrapper with strong references to underlying dict
      // end copy-paste
      
      if singleValueForKeyDict != nil {
        // TODO: instead of checking `hasValue(forKey:)` use `update()` and check if result != nil
        // measure time which is faster
        if singleValueForKeyDict.hasValue(forKey: newKey) {
          var multiValueForKeyDict = MultiValueForKeyDict()
          for (currentKey, currentValue) in singleValueForKeyDict {
            multiValueForKeyDict[currentKey] = WrappedValue.value(currentValue)
          }
          let newValueWrapped = WrappedValue.collidedValue(newValue, collisionSpecifier: collisionSourceSpecifier())
          multiValueForKeyDict.append(key: newKey, value: newValueWrapped)
          _variant = .right(multiValueForKeyDict)
        } else {
          singleValueForKeyDict[newKey] = newValue
          _variant = .left(singleValueForKeyDict)
        }
      } else if multiValueForKeyDict != nil {
        let newValueWrapped: WrappedValue = if multiValueForKeyDict.hasValue(forKey: newKey) {
          .collidedValue(newValue, collisionSpecifier: collisionSourceSpecifier())
        } else {
          .value(newValue)
        }
        multiValueForKeyDict.append(key: newKey, value: newValueWrapped)
        _variant = .right(multiValueForKeyDict)
      }
    }
  }
}

extension OrderedMultipleValuesForKeyStorage._Variant: Sendable where Key: Sendable, Value: Sendable {}
