//
//  ErrorInfoDictFuncs.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 31/07/2025.
//

// MARK: Add Key Prefix

extension ErrorInfoFuncs.DictUtils {
  /// No collisions can happen doing this operation.
  @inlinable @inline(__always) // 2.4x speedup
  public static func addKeyPrefix<Dict>(_ keyPrefix: Dict.Key, toKeysOf dict: Dict) -> Dict
    where Dict: DictionaryProtocol, Dict: EmptyInitializableWithCapacityDictionary, Dict.Key: RangeReplaceableCollection {
    var prefixedKeysDict = Dict(minimumCapacity: dict.count)
      
    for (key, value) in dict {
      let prefixedKey = keyPrefix + key
      prefixedKeysDict[prefixedKey] = value
    }
      
    return prefixedKeysDict
  }
}
