//
//  ErrorInfoDictMerge.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 31/07/2025.
//

/// all merge functions have no default value for omitEqualValue arg.
/// Extension can be be made on user side, providing overload with suitable default choice.
extension Merge.DictUtils {
  // MARK: Merge
  
  /// The purpose of this function is to merge multiple dictionaries of error information into a single dictionary, handling any key collisions by appending a unique suffix to the key.
  ///
  /// The function loops through each dictionary in the `otherInfos` array and for each dictionary, it loops through its key-value pairs.2
  /// For each key-value pair, the function checks if the key already exists in the `errorInfo` dictionary.
  /// If the key does not already contained in the `errorInfo` dictionary, the function simply adds this key-value pair to the `errorInfo` dictionary.
  /// If it is contained, the function checks if the value is approximately equal to the existing value in the `errorInfo` dictionary.
  /// If they are approximately equal, then the function leaves in the dictionary the value that is already there
  /// If not, then the function modifies the key by appending a generated suffix consisting of the current line number and the `index` of the current dictionary in the `otherInfos` array.
  /// The function then checks if the modified key already exists in the errorInfo dictionary.
  /// If it does, it appends the index of the current dictionary to the suffix and checks again until it finds a key that does not exist in the `errorInfo` dictionary.
  /// Once it finds a unique key, the function adds the key-value pair to the `errorInfo` dictionary.
  internal static func _mergeErrorInfo<V, C>(
    _ recipient: inout some DictionaryProtocol<String, V>,
    with donators: [some DictionaryProtocol<String, V>],
    omitEqualValue: Bool,
    identity: C,
    randomGenerator: consuming some RandomNumberGenerator & Sendable = SystemRandomNumberGenerator(),
    resolve: @Sendable (ResolvingInput<String, V, C>) -> ResolvingResult<String>,
  ) {
    for (donatorIndex, donator) in donators.enumerated() {
      for donatorElement in donator {
        withKeyAugmentationAdd(keyValue: donatorElement,
                               to: &recipient,
                               donatorIndex: donatorIndex,
                               omitEqualValue: omitEqualValue,
                               identity: identity,
                               randomGenerator: &randomGenerator,
                               resolve: resolve)
      } // end for (key, value)
    } // end for (index, otherInfo)
  }
  
//   repeat (each Dict).Key == String  Not supported by Swift yet, wait for some swift 6.x > 6.2
//  internal static func _mergeErrorInfo<V, each Dict>(_ recipient: inout some DictionaryUnifyingProtocol<String, V>,
//                                          with donators: repeat each Dict,
//                                          omitEqualValue: Bool,
//                                          fileLine: StaticFileLine,
//                                          resolve: (ResolvingInput<String, V>) -> ResolvingResult<String>)
//  where repeat each Dict: DictionaryUnifyingProtocol, repeat (each Dict).Key == String {
//    for donator in repeat each donators {
//      for donatorElement in donator {
//        withResolvingCollisionsAdd(keyValue: donatorElement,
//                                   to: &recipient,
//                                   donatorIndex: donatorIndex,
//                                   omitEqualValue: omitEqualValue,
//                                   fileLine: fileLine,
//                                   resolve: resolve)
//      } // end for (key, value)
//    } // end for (index, otherInfo)
//  }
}

// MARK: - Low level root functions for a single value

extension Merge.DictUtils {
  // short typealiased names for convenience:
  public typealias ResolvingInput<Key: Hashable, Value, C> = KeyCollisionResolvingInput<Key, Value, C>
  public typealias ResolvingResult<Key: Hashable> = KeyCollisionResolvingResult<Key>
  // TODO: ?? rename to Input / ResolvingResult as there are no other inputs in Merge namespace
}

// MARK: - Key Augmentation (String overload)

extension Merge.DictUtils {
  /// Add value by key to recipient` dictionary`.
  /// For key-value pair, the function checks if the key already exists in the `recipient` dictionary.
  /// If the key does not already contained in the `recipient` dictionary, the function simply adds this key-value pair to the `recipient` dictionary.
  /// If it is contained, the function checks if the value is approximately equal to the existing value in the `recipient` dictionary.
  /// If they are approximately equal, then the function leaves in the dictionary the value that is already there
  /// If not, then the function modifies the key by appending a generated suffix consisting of the current line number and the `index`.
  /// The function then checks if the modified key already exists in the errorInfo dictionary.
  /// If it does, it appends the index of the current dictionary to the suffix and checks again until it finds a key that does not exist in the `errorInfo` dictionary.
  /// Once a unique key is finally created (typically it happens from first time), the function adds the key-value pair to the `recipient` dictionary.
  /// - Parameters:
  ///   - donatorKeyValue:
  ///   - recipient:
  ///   - donatorIndex:
  ///   - shouldOmitEqualValue:
  ///   - identity:
  ///   - resolve:
  public static func withKeyAugmentationAdd<Dict, C>(keyValue donatorKeyValue: Dict.Element,
                                                     to recipient: inout Dict,
                                                     donatorIndex: some BinaryInteger & CustomStringConvertible,
                                                     omitEqualValue shouldOmitEqualValue: Bool,
                                                     identity: C,
                                                     randomGenerator: inout some RandomNumberGenerator & Sendable,
                                                     resolve: (ResolvingInput<Dict.Key, Dict.Value, C>) -> ResolvingResult<Dict.Key>)
    where Dict: DictionaryProtocol, Dict.Key == String {
    // TODO: update func documentation
    let suffixFirstChar: UnicodeScalar = Merge.Constants.randomSuffixBeginningForMergeScalar
    withKeyAugmentationAdd(keyValue: donatorKeyValue,
                           to: &recipient,
                           donatorIndex: donatorIndex,
                           omitEqualValue: shouldOmitEqualValue,
                           identity: identity,
                           suffixSeparator: String(suffixFirstChar),
                           randomGenerator: &randomGenerator,
                           randomSuffix: Merge.Utils.randomSuffix,
                           resolve: resolve)
  }
  
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
}

// MARK: - Key Augmentation (generic)

import NonEmpty

extension Merge.DictUtils {
  // ResolvingResult should have one more case: .builtInAddSuffix, and Never type used to make it (un)available for different imps.
  // For Collection-Type keys it is possible to append random-suffix
  
  internal static func withKeyAugmentationAdd<Dict, C, RGen>(keyValue donatorKeyValue: Dict.Element,
                                                             to recipient: inout Dict,
                                                             donatorIndex: some BinaryInteger & CustomStringConvertible,
                                                             omitEqualValue omitIfEqual: Bool,
                                                             identity: C,
                                                             suffixSeparator: some Collection<Dict.Key.Element>,
                                                             randomGenerator: inout RGen,
                                                             randomSuffix: @Sendable (inout RGen) -> NonEmpty<Dict.Key>,
                                                             resolve: (ResolvingInput<Dict.Key, Dict.Value, C>) -> ResolvingResult<Dict.Key>)
    where Dict: DictionaryProtocol, Dict.Key: RangeReplaceableCollection, RGen: RandomNumberGenerator {
    let (donatorKey, donatorValue) = donatorKeyValue
    // In, most cases value is simply added to recipient. When collision happens, it must be properly resolved.
    if let recipientValue = recipient[donatorKey] {
      let collidedKey = donatorKey
      // if collision happened, but values are equal, then we can keep existing value
      lazy var isEqualToCurrent = ErrorInfoFuncs.isEqualAny(recipientValue, donatorValue)
      let resolvingResult: KeyCollisionResolvingResult<Dict.Key>
      if omitIfEqual, isEqualToCurrent {
        return
      } else {
        typealias Input = KeyCollisionResolvingInput<Dict.Key, Dict.Value, C>
        let element = Input.Element(key: collidedKey, existingValue: recipientValue, beingAddedValue: donatorValue)
        let resolvingInput = Input(element: element,
                                   areValuesApproximatelyEqual: isEqualToCurrent,
                                   donatorIndex: donatorIndex,
                                   identity: identity)
        resolvingResult = resolve(resolvingInput)
      }
      
      func putAugmentingWithRandomSuffix_(_ value: Dict.Value, assumeModifiedKey: Dict.Key) {
        _putAugmentingWithRandomSuffix(assumeModifiedKey: assumeModifiedKey,
                                       value: value,
                                       shouldOmitEqualValue: omitIfEqual,
                                       suffixSeparator: suffixSeparator,
                                       randomGenerator: &randomGenerator,
                                       randomSuffix: randomSuffix,
                                       to: &recipient)
      }
      
      switch resolvingResult {
      case let .modifyDonatorKey(assumeWasModifiedDonatorKey):
        putAugmentingWithRandomSuffix_(donatorValue, assumeModifiedKey: assumeWasModifiedDonatorKey)
        
      case let .modifyRecipientKey(assumeWasModifiedRecipientKey):
        // 1. replace value that was already contained in recipient by donatorValue
        recipient[collidedKey] = donatorValue
        // 2. put value that was already contained in recipient by modifiedRecipientKey
        putAugmentingWithRandomSuffix_(recipientValue, assumeModifiedKey: assumeWasModifiedRecipientKey)
        
      case let .modifyBothKeys(assumeWasModifiedDonatorKey, assumeWasModifiedRecipientKey):
        recipient[collidedKey] = nil // remove old key & value
        putAugmentingWithRandomSuffix_(donatorValue, assumeModifiedKey: assumeWasModifiedDonatorKey)
        putAugmentingWithRandomSuffix_(recipientValue, assumeModifiedKey: assumeWasModifiedRecipientKey)
      }
    } else { // if no collisions then add to recipient
      recipient[donatorKey] = donatorValue
    }
  }
  
  /// Decomposition subroutine of `func withKeyAugmentationAdd(...)`
  internal static func _putAugmentingWithRandomSuffix<Dict, RGen>(
    assumeModifiedKey: Dict.Key,
    value: Dict.Value,
    shouldOmitEqualValue omitIfEqual: Bool,
    suffixSeparator: some Collection<Dict.Key.Element>,
    randomGenerator: inout RGen,
    randomSuffix: @Sendable (inout RGen) -> NonEmpty<Dict.Key>,
    to recipient: inout Dict,
  )
    where Dict: DictionaryProtocol, Dict.Key: RangeReplaceableCollection, RGen: RandomNumberGenerator {
    // Here we can can only make an assumtption that donator key was modified on the client side.
    // While it should always happen, there is no guarantee.
    
    // So there are 2 possible collision variants here:
    // 1. assumeWasModifiedDonatorKey was not really modified
    // 2. assumeWasModifiedDonatorKey was modified but also has a collision with another existing key of recipient
    var modifiedKey = assumeModifiedKey
    var needToAddSuffixSeparator = true
    while let recipientAnotherValue = recipient[modifiedKey] { // condition mostly always should not happen
      lazy var isEqualToCurrent = ErrorInfoFuncs.isEqualAny(recipientAnotherValue, value)
            
      if omitIfEqual, isEqualToCurrent { // if newly added value is equal to current, then keep only existing
        return // Early exit
      } else {
        let randomSuffix = randomSuffix(&randomGenerator)
        
        let suffix = mutate(value: Dict.Key()) { // counter == 0 ? String(suffixFirstChar) + randomSuffix : randomSuffix
          if needToAddSuffixSeparator {
            $0.append(contentsOf: suffixSeparator) // suffixSeparator can be empty, which is effectively an absence of it
            $0.append(contentsOf: randomSuffix.rawValue)
            needToAddSuffixSeparator = false
          } else {
            $0 = randomSuffix.rawValue
          }
        }
        
        modifiedKey.append(contentsOf: suffix) // modifiedKey += suffix
        // example: 3 error-info instances with decodingDate key
        // "decodingDate_don0_file_line_SourceFileName_81_#9vT"
      }
    } // end while
    recipient[modifiedKey] = value
  }
  
  internal static func _putAugmentingWithRandomSuffix<Dict, NumGen>(
    assumeModifiedKey: Dict.Key,
    value: Dict.Value,
    suffixSeparator: some Collection<Dict.Key.Element>,
    randomGenerator: inout NumGen,
    randomSuffix: @Sendable (inout NumGen) -> NonEmpty<Dict.Key>,
    to recipient: inout Dict,
  )
    where Dict: DictionaryProtocol, Dict.Key: RangeReplaceableCollection, NumGen: RandomNumberGenerator {
    // Here we can can only make an assumtption that donator key was modified on the client side.
    // While it should always happen, there is no guarantee.
    
    // So there are 2 possible collision variants here:
    // 1. assumeWasModifiedDonatorKey was not really modified
    // 2. assumeWasModifiedDonatorKey was modified but also has a collision with another existing key of recipient
    var modifiedKey = assumeModifiedKey
    var needToAddSuffixSeparator = true
    while recipient.hasValue(forKey: modifiedKey) { // condition mostly always should not happen
      let randomSuffix = randomSuffix(&randomGenerator)
      
      let suffix = mutate(value: Dict.Key()) { // counter == 0 ? String(suffixFirstChar) + randomSuffix : randomSuffix
        if needToAddSuffixSeparator {
          $0.append(contentsOf: suffixSeparator) // suffixSeparator can be empty, which is effectively an absence of it
          $0.append(contentsOf: randomSuffix.rawValue)
          needToAddSuffixSeparator = false
        } else {
          $0 = randomSuffix.rawValue
        }
      }
      
      modifiedKey.append(contentsOf: suffix) // modifiedKey += suffix
      // example: 3 error-info instances with decodingDate key
      // "decodingDate_don0_file_line_SourceFileName_81_#9vT"
    } // end while
    recipient[modifiedKey] = value
  }
}
