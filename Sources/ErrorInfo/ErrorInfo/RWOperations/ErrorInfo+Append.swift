//
//  ErrorInfo+Append.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Append

extension ErrorInfo {
  /// Instead of subscript overload with `String` key to prevent pollution of autocomplete for `ErronInfoLiteralKey` by tons of String methods.
  @_disfavoredOverload
  public mutating func append(key dynamicKey: String, value newValue: (some ValueType)?) {
    _add(key: dynamicKey,
         value: newValue,
         preserveNilValues: true,
         insertIfEqual: false,
         addTypeInfo: .default,
         collisionSource: .onSubscript(keyKind: .dynamic))
  }
  
  
  @available(*, deprecated, message: "for literal keys use subscript instead, append() is intended for dynamic keys)")
  public mutating func append(key literalKey: ErronInfoLiteralKey, value newValue: (some ValueType)?) {
    // deprecattion is used to guide users
    _add(key: literalKey.rawValue,
         value: newValue,
         preserveNilValues: true,
         insertIfEqual: false,
         addTypeInfo: .default,
         collisionSource: .onSubscript(keyKind: .literalConstant))
  }
}

// MARK: Append IfNotNil

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

// MARK: Append ContentsOf

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
