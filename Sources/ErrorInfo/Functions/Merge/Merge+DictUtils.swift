//
//  ErrorInfoDictMerge.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 31/07/2025.
//

import NonEmpty

// MARK: - Put Augmenting With Random Suffix

extension Merge.DictUtils {
  // MARK: - String Imps
  
  /// decomposition subroutine of func withResolvingCollisionsAdd()
  internal static func _putAugmentingWithRandomSuffix<Dict>(_ value: Dict.Value,
                                                            assumeModifiedKey: Dict.Key,
                                                            shouldOmitEqualValue: Bool,
                                                            suffixFirstChar: UnicodeScalar,
                                                            randomGenerator: inout some RandomNumberGenerator & Sendable,
                                                            to recipient: inout Dict)
    where Dict: DictionaryProtocol, Dict.Key == String {
    _putAugmentingWithRandomSuffix(assumeModifiedKey: assumeModifiedKey,
                                   value: value,
                                   shouldOmitEqualValue: shouldOmitEqualValue,
                                   suffixSeparator: String(suffixFirstChar),
                                   randomGenerator: &randomGenerator,
                                   randomSuffix: Merge.Utils.randomSuffix,
                                   to: &recipient)
  }
  
  internal static func _putAugmentingWithRandomSuffix<Dict>(assumeModifiedKey: Dict.Key,
                                                            value: Dict.Value,
                                                            suffixFirstChar: UnicodeScalar,
                                                            randomGenerator: inout some RandomNumberGenerator & Sendable,
                                                            to recipient: inout Dict)
    where Dict: DictionaryProtocol, Dict.Key == String {
    _putAugmentingWithRandomSuffix(assumeModifiedKey: assumeModifiedKey,
                                   value: value,
                                   suffixSeparator: String(suffixFirstChar),
                                   randomGenerator: &randomGenerator,
                                   randomSuffix: Merge.Utils.randomSuffix,
                                   to: &recipient)
  }
  
  // MARK: - Generic Imps
  
  /// Decomposition subroutine of `func withKeyAugmentationAdd(...)`
  internal static func _putAugmentingWithRandomSuffix<Dict, RndGen>(
    assumeModifiedKey: Dict.Key,
    value: Dict.Value,
    shouldOmitEqualValue omitIfEqual: Bool,
    suffixSeparator: some Collection<Dict.Key.Element>,
    randomGenerator: inout RndGen,
    randomSuffix: @Sendable (inout RndGen) -> NonEmpty<Dict.Key>,
    to recipient: inout Dict,
  ) where Dict: DictionaryProtocol, Dict.Key: RangeReplaceableCollection, RndGen: RandomNumberGenerator {
    // Here we can can only make an assumtption that donator key was modified on the client side.
    // While it should always happen, there is no guarantee.
    // So there are 2 possible collision variants here:
    // 1. assumeModifiedKey was not really modified
    // 2. assumeModifiedKey was modified but also has a collision with another existing key of recipient
    
    var modifiedKey = assumeModifiedKey
    var needToAddSuffixSeparator = true
    while let recipientAnotherValue = recipient[modifiedKey] { // condition mostly always should not happen
      lazy var isEqualToCurrent = ErrorInfoFuncs.isEqualAny(recipientAnotherValue, value)
      // FIXME: ErrorInfoFuncs.isEqualAny – inject comparator func
      if omitIfEqual, isEqualToCurrent { // if newly added value is equal to current, then keep only existing
        return // Early exit
      } else {
        let randomSuffix = randomSuffix(&randomGenerator)
        
        let suffix = mutate(value: Dict.Key()) {
          if needToAddSuffixSeparator {
            $0.append(contentsOf: suffixSeparator) // suffixSeparator can be empty, which is effectively an absence of it
            $0.append(contentsOf: randomSuffix.base)
            needToAddSuffixSeparator = false
          } else {
            $0 = randomSuffix.base
          }
        }
        
        modifiedKey.append(contentsOf: suffix)
      }
    } // end while
      
    recipient[modifiedKey] = value
  }
  
  internal static func _putAugmentingWithRandomSuffix<Dict, RndGen>(
    assumeModifiedKey: Dict.Key,
    value: Dict.Value,
    suffixSeparator: some Collection<Dict.Key.Element>,
    randomGenerator: inout RndGen,
    randomSuffix: @Sendable (inout RndGen) -> NonEmpty<Dict.Key>,
    to recipient: inout Dict,
  ) where Dict: DictionaryProtocol, Dict.Key: RangeReplaceableCollection, RndGen: RandomNumberGenerator {
    // Here we can can only make an assumtption that donator key was modified on the client side.
    // While it should always happen, there is no guarantee.
    // So there are 2 possible collision variants here:
    // 1. assumeModifiedKey was not really modified
    // 2. assumeModifiedKey was modified but also has a collision with another existing key of recipient
    
    var modifiedKey = assumeModifiedKey
    var needToAddSuffixSeparator = true
    while recipient.hasValue(forKey: modifiedKey) { // condition mostly always should not happen
      let randomSuffix = randomSuffix(&randomGenerator)
      
      let suffix = mutate(value: Dict.Key()) {
        if needToAddSuffixSeparator {
          // Improvement: ? $0.reserveCapacity()
          $0.append(contentsOf: suffixSeparator) // suffixSeparator can be empty, which is effectively an absence of it
          $0.append(contentsOf: randomSuffix.base)
          needToAddSuffixSeparator = false
        } else {
          $0 = randomSuffix.base
        }
      }
      
      modifiedKey.append(contentsOf: suffix)
    } // end while
      
    recipient[modifiedKey] = value
  }
}
