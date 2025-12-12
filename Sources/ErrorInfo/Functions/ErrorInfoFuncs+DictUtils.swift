//
//  ErrorInfoDictFuncs.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 31/07/2025.
//

// MARK: Add Key Prefix

extension ErrorInfoFuncs.DictUtils {
  /// Adds the specified prefix to all keys in the dictionary, returning a new dictionary with the modified keys.
  ///
  /// - Parameters:
  ///   - keyPrefix: The prefix to be added to each key.
  ///   - dict: The dictionary whose keys are to be prefixed.
  /// - Returns: A new dictionary with the prefixed keys.
  ///
  /// Example:
  /// ```swift
  /// let dict = ["key1": 1, "key2": 2]
  /// let prefixedDict = ErrorInfoFuncs.DictUtils.addKeyPrefix("prefix_", toKeysOf: dict)
  /// // prefixedDict == ["prefix_key1": 1, "prefix_key2": 2]
  /// ```
  @inlinable @inline(__always) // 2.4x speedup
  public static func addKeyPrefix<Dict>(_ keyPrefix: Dict.Key, toKeysOf dict: Dict) -> Dict
    where Dict: DictionaryProtocol, Dict: EmptyInitializableWithCapacityDictionary, Dict.Key: RangeReplaceableCollection {
    // No collisions can happen doing this operation.
    var prefixedKeysDict = Dict(minimumCapacity: dict.count)
      
    for (key, value) in dict {
      let prefixedKey = keyPrefix + key
      prefixedKeysDict[prefixedKey] = value
    }
      
    return prefixedKeysDict
  }
}
