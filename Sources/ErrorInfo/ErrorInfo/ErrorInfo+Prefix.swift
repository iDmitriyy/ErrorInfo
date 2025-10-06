//
//  ErrorInfo+Prefix.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

// MARK: Prefix & Suffix

extension ErrorInfo {
  public mutating func addKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc) {
//    ErrorInfoDictFuncs.addKeyPrefix(keyPrefix,
//                                    toKeysOf: &_storage,
//                                    transform: transform)
  }
  
  public consuming func addingKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc) -> Self {
    addKeyPrefix(keyPrefix, transform: transform)
    return self
  }
}
