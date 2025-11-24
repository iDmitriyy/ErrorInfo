//
//  ErrorInfo+Append.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Append

// MARK: appendIfNotNil

extension ErrorInfo {
  public mutating func appendIfNotNil(_ value: (any ValueType)?,
                                      forKey literalKey: ErronInfoLiteralKey,
                                      insertIfEqual: Bool = false) {
    guard let value else { return }
    _appendWithDefaultTypeInfo(key: literalKey.rawValue,
                               value: value,
                               preserveNilValues: true, // has no effect in this func
                               insertIfEqual: insertIfEqual,
                               keyKind: .literalConstant)
  }
  
  @_disfavoredOverload
  public mutating func appendIfNotNil(_ value: (any ValueType)?,
                                      forKey dynamicKey: String,
                                      insertIfEqual: Bool = false) {
    guard let value else { return }
    _appendWithDefaultTypeInfo(key: dynamicKey,
                               value: value,
                               preserveNilValues: true, // has no effect in this func
                               insertIfEqual: insertIfEqual,
                               keyKind: .dynamic)
  }
}

// MARK: Append contentsOf

extension ErrorInfo {
  public mutating func append(contentsOf sequence: some Sequence<(String, any ValueType)>, insertIfEqual: Bool = false) {
    for (key, value) in sequence {
      _appendWithDefaultTypeInfo(key: key,
                                 value: value,
                                 preserveNilValues: true, // has no effect in this func
                                 insertIfEqual: insertIfEqual,
                                 keyKind: .dynamic)
    }
  }
}

extension ErrorInfo {
  private mutating func _appendWithDefaultTypeInfo(key: Key,
                                                   value: any ValueType,
                                                   preserveNilValues: Bool, // always true at call sites, need if value become optional
                                                   insertIfEqual: Bool,
                                                   keyKind: CollisionSource.KeyKind) {
    _add(key: key,
         value: value,
         preserveNilValues: preserveNilValues,
         insertIfEqual: insertIfEqual,
         addTypeInfo: .default,
         collisionSource: .onAppend(keyKind: keyKind))
  }
}
