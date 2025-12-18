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
  
  /// **Overload for String type**.
  /// Inserts a key-value pair into the dictionary, appending a random suffix to the key if a collision occurs.
  ///
  /// If a key already exists in the dictionary, the function appends a random suffix to the key
  /// (and repeats this process) until the key becomes unique.
  ///
  /// If the value being inserted is equal to the current value for the same key, the insertion is skipped
  /// if omitIfEqual == true, otherwise add duplicate.
  ///
  /// ```swift
  /// var dict = ["apple": 1]
  ///
  /// // Attempt to insert a new key-value pair with the key "apple"
  /// _putAugmentingWithRandomSuffix(
  ///     value: 2,
  ///     assumeModifiedKey: "apple",
  ///     shouldOmitEqualValue: false,
  ///     suffixFirstChar: Merge.Constants.randomSuffixBeginningForSubcriptScalar,
  ///     randomGenerator: &randomGenerator,
  ///     to: &dict
  /// )
  /// print(dict)
  /// // Output: ["apple": 1, "apple$y7HM": 2]
  /// ```
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
  
  /// **Overload for String type**.
  /// Inserts a key-value pair into the dictionary, appending a random suffix to the key if a collision occurs.
  ///
  /// If a key already exists in the dictionary, the function appends a random suffix to the key
  /// (and repeats this process) until the key becomes unique.
  ///
  /// ```swift
  /// var dict = ["apple": 1]
  ///
  /// // Attempt to insert a new key-value pair with the key "apple"
  /// _putAugmentingWithRandomSuffix(
  ///     value: 2,
  ///     assumeModifiedKey: "apple",
  ///     suffixFirstChar: Merge.Constants.randomSuffixBeginningForSubcriptScalar,
  ///     randomGenerator: &randomGenerator,
  ///     to: &dict
  /// )
  /// print(dict)
  /// // Output: ["apple": 1, "apple$y7HM": 2]
  /// ```
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
  
  /// **Generic RangeReplaceableCollection Imp**.
  /// Inserts a key-value pair into the dictionary, appending a random suffix to the key if a collision occurs.
  ///
  /// If a key already exists in the dictionary, the function appends a random suffix to the key
  /// (and repeats this process) until the key becomes unique.
  ///
  /// If the value being inserted is equal to the current value for the same key, the insertion is skipped
  /// if omitIfEqual == true, otherwise add duplicate.
  ///
  /// ```swift
  /// var dict = ["apple": 1]
  ///
  /// // Attempt to insert a new key-value pair with the key "apple"
  /// _putAugmentingWithRandomSuffix(
  ///     value: 2,
  ///     assumeModifiedKey: "apple",
  ///     shouldOmitEqualValue: false,
  ///     suffixFirstChar: Merge.Constants.randomSuffixBeginningForSubcriptScalar,
  ///     randomGenerator: &randomGenerator,
  ///     randomSuffix: Merge.Utils.randomSuffix,
  ///     to: &dict
  /// )
  /// print(dict)
  /// // Output: ["apple": 1, "apple$y7HM": 2]
  /// ```
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
  
  /// **Generic RangeReplaceableCollection Imp**.
  /// Inserts a key-value pair into the dictionary, appending a random suffix to the key if a collision occurs.
  ///
  /// If a key already exists in the dictionary, the function appends a random suffix to the key
  /// (and repeats this process) until the key becomes unique.
  ///
  /// ```swift
  /// var dict = ["apple": 1]
  ///
  /// // Attempt to insert a new key-value pair with the key "apple"
  /// _putAugmentingWithRandomSuffix(
  ///     value: 2,
  ///     assumeModifiedKey: "apple",
  ///     suffixFirstChar: Merge.Constants.randomSuffixBeginningForSubcriptScalar,
  ///     randomGenerator: &randomGenerator,
  ///     randomSuffix: Merge.Utils.randomSuffix,
  ///     to: &dict
  /// )
  /// print(dict)
  /// // Output: ["apple": 1, "apple$y7HM": 2]
  /// ```
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
