//
//  ErrorInfo+ToDictionary.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 10/10/2025.
//

extension ErrorInfo {
  // collapseNilInstances: Bool = false
  public func asStringDict(collisionSourceInterpolation: (CollisionSource) -> String = { $0.defaultStringInterpolation() })
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
      dict[effectiveKey] = String(describing: wrappedValue.value)
    }
    return dict
  }
  
  public func asDictionary<V>() ->[String: V] {
    [:]
  }
  
  public func asEncodableDictionary<V>() ->[String: V] {
    [:]
  }
}
