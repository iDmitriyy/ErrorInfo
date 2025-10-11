//
//  ErrorInfo+ToDictionary.swift
//  ErrorInfo
//
//  Created by tmp on 10/10/2025.
//

extension ErrorInfo {
  public func asStringDict(collisionSourceInterpolation: (StringBasedCollisionSource) -> String = { $0.defaultStringInterpolation() })
    -> [String: String] { // TODO: should be a protocol default imp
    var dict = [String: String](minimumCapacity: _storage.count)
    _storage.forEach { key, wrappedValue in // TODO: use builtin initializer of OrderedDict instead of foreach
      // TODO: use prefix / suffix transforms for augmenting keys
      let effectiveKey: String = if let collisionSource = wrappedValue.collisionSource {
        key + collisionSourceInterpolation(collisionSource)
      } else {
        key
      }
      // FIXME: use `withKeyAugmentationAdd(...)`
      dict[key] = String(describing: wrappedValue.value)
    }
    return dict
  }
  
  public func asDictionary<V>() ->[String: V] {
    [:]
  }
}
