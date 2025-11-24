//
//  ErrorInfo+HasValueForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: HasValues ForKey

extension ErrorInfo {
  public func hasValues(forKey key: ErronInfoLiteralKey) -> Bool {
    _storage.hasValue(forKey: key.rawValue)
  }
  
  @_disfavoredOverload
  public func hasValues(forKey key: Key) -> Bool {
    _storage.hasValue(forKey: key)
  }
  
  // func hasCollisions() -> Bool {}
  
  // func hasCollisions(forKey key: ErronInfoLiteralKey) -> Bool {}
  
  // @_disfavoredOverload
  // func hasCollisions(forKey key: Key) -> Bool {}
}

// MARK: HasNonNilValues ForKey

// TODO: implement
// extension ErrorInfo {
//  public func hasNonNilValues(forKey key: ErronInfoLiteralKey) -> Bool {
//    hasNonNilValues(forKey: key.rawValue)
//  }
//
//  public func hasNonNilValues(forKey key: Key) -> Bool {
//
//  }
// }
