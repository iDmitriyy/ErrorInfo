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
  public mutating func append(key dynamicKey: String, value newValue: (some ValueProtocol)?) {
    _add(key: dynamicKey,
         keyOrigin: .dynamic,
         value: newValue,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         collisionSource: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead
  }
  
  @available(*, deprecated, message: "for literal keys use subscript instead, append() is intended for dynamic keys)")
  public mutating func append(key literalKey: StringLiteralKey, value newValue: (some ValueProtocol)?) {
    // deprecattion is used to guide users
    _add(key: literalKey.rawValue,
         keyOrigin: literalKey.keyOrigin,
         value: newValue,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         collisionSource: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: Append IfNotNil

extension ErrorInfo {
  public mutating func appendIfNotNil(_ value: (some ValueProtocol)?,
                                      forKey literalKey: StringLiteralKey,
                                      duplicatePolicy: ValueDuplicatePolicy = .rejectEqual) {
    guard let value else { return }
    _singleKeyValuePairAppend(key: literalKey.rawValue,
                              keyOrigin: literalKey.keyOrigin,
                              value: value,
                              duplicatePolicy: duplicatePolicy)
  }
  
  @_disfavoredOverload
  public mutating func appendIfNotNil(_ value: (some ValueProtocol)?,
                                      forKey dynamicKey: String,
                                      duplicatePolicy: ValueDuplicatePolicy = .rejectEqual) {
    guard let value else { return }
    _singleKeyValuePairAppend(key: dynamicKey,
                              keyOrigin: .dynamic,
                              value: value,
                              duplicatePolicy: duplicatePolicy)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErrorInfo {
  internal mutating func _singleKeyValuePairAppend(key: String,
                                                   keyOrigin: KeyOrigin,
                                                   value: some ValueProtocol,
                                                   duplicatePolicy: ValueDuplicatePolicy) {
    _add(key: key,
         keyOrigin: keyOrigin,
         value: value,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: duplicatePolicy,
         collisionSource: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead
  }
}
