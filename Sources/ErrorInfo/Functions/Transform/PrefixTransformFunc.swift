//
//  PrefixTransformFunc.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16/09/2025.
//

// TODO: use something like `MutableMoveOnly` to mutate the same String buffer instead of multiple allocations when
// transforms are combined

public struct PrefixTransformFunc: Sendable {
  public typealias TransformFunc = @Sendable (_ key: String, _ prefix: String) -> String
  
  private let body: TransformFunc
  
  /// identity for debug purposes, .left – name, .right - file & line
  private let _identity: String
  
  public init(body: @escaping TransformFunc, file: String = #fileID) {
    self.body = body
    _identity = file
  }
  
  public init(body: @escaping TransformFunc, identifier: String) {
    self.body = body
    _identity = identifier
  }
  
  internal func callAsFunction(key: String, prefix: String) -> String {
    body(key, prefix)
  }
}

extension PrefixTransformFunc {
  public static let concatenation =
    PrefixTransformFunc(body: { key, prefix in prefix + key },
                        identifier: "concatenation prefix + key")
  
//  public static let concatenationUppercasingKeyFirstChar =
//    PrefixTransformFunc(body: { key, prefix in prefix + key.uppercasingFirstLetter() },
//                        identifier: "concatenation prefix + key.uppercasingFirstLetter()")
}

// MARK: - Composite Transform

// FIXME: - to do implementation.
// May be it is better to make a more general KeyTransform type, where add prefix-like operations, suffix-like and mapping
// will be prsent as different favors of Key-tranform.
// There is a limited set of reasonable kinds of key mappings:
// - Allow to make changes at characters at arbitrary postions, but the overall count / lenght is >= than original.
//   Something similar to outputSpan
// - prefix + optional separator["" if not needed] + inout first char
// - inout last char + optional separator["" if not needed] + suffix
// - providing a view with limited builtin operations like converting to camel / pascal case
// - unverifiedResult mapping, allowing to completely replace key, for custom logic. `unverified` term handles some sort
// of unsafety and increased attention / cauton. Even though collisions will be resolved, the error info keys can be corrupted
// to something unreadable / meaningless.
public struct PrefixCompositeTransformFunc: Sendable {
  public typealias TransformFunc = @Sendable (_ key: String, _ prefix: String) -> String
  
  private let funcs: [TransformFunc]
  
  private let _identity: String
  
  public init(funcs: [TransformFunc], file: String = #fileID) {
    self.funcs = funcs
    _identity = file
  }
  
  public init(funcs: [TransformFunc], identifier: String) {
    self.funcs = funcs
    _identity = identifier
  }
}

/*
 Usage:
 
 merge(transformKey: .prependWith(prefix), .prependWith("_"), .uppercaseFirst)
 or
 merge(transformKey: { $0.uppercaseFirst.prependWith("prefix", "_") })
 
 firstly all transformations are applied for each key and then final result after all transformations is used as a key
 So collisions are resolved for final result of key transformations (not to intermediate results)
 
 // ?? how to convert different key styles?
 */

extension Merge.DictUtils {
  public static func addKeyPrefix<V, Dict>(
    _ keyPrefix: String,
    toKeysOf dict: inout Dict,
    randomGenerator: consuming some RandomNumberGenerator & Sendable = SystemRandomNumberGenerator(),
    transform: PrefixTransformFunc,
  ) where Dict: DictionaryProtocol<String, V>, Dict: EmptyInitializableWithCapacityDictionary {
    var prefixedKeysDict = Dict(minimumCapacity: dict.count)
    
    // Adding prefix is similar to merge operation, except that key collisions can happen between own keys after they are transformed.
    // The are no donators, so use lower level soubroutine.
    // Example:
    // ["a": 1, "A": 2]
    // - Add a prefix == "product", with uppercasingKeyFirstChar
    // - key "a" will be uppercased which introduces a collision
    // After colissions resolving:
    // ["productA": 1, "productA#pL4A": 2]
    
    // While appearing of equal values making a merge is expected, such situation is not normal when adding a prefix
    // to all keys.
    // such self-collisions are something unexpected, so keep all values (shouldOmitEqualValue = false) in this case
    for (key, value) in dict {
      let prefixedKey = transform(key: key, prefix: keyPrefix)
      Merge.DictUtils._putAugmentingWithRandomSuffix(value,
                                                     assumeModifiedKey: prefixedKey,
                                                     shouldOmitEqualValue: false,
                                                     suffixFirstChar: Merge.Constants.randomSuffixBeginningForMergeScalar,
                                                     randomGenerator: &randomGenerator,
                                                     to: &prefixedKeysDict)
    }
    return dict = prefixedKeysDict
  }
}
