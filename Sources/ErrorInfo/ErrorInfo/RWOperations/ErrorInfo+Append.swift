//
//  ErrorInfo+Append.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Append

extension ErrorInfo {
  /// Instead of subscript overload with `String` key to prevent pollution of autocomplete for `StringLiteralKey` by tons of String methods.
  @_disfavoredOverload
  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) {
    _add(key: dynamicKey,
         keyOrigin: .dynamic,
         value: newValue,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
  
  @available(*, deprecated, message: "for literal keys use subscript instead, append() is intended for dynamic keys)")
  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey literalKey: StringLiteralKey) {
    // deprecattion is used to guide users
    _add(key: literalKey.rawValue,
         keyOrigin: literalKey.keyOrigin,
         value: newValue,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: Append IfNotNil

extension ErrorInfo {
  public mutating func appendIfNotNil(_ value: (some ValueProtocol)?,
                                      forKey literalKey: StringLiteralKey,
                                      duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending) {
    guard let value else { return }
    _singleKeyValuePairAppend(key: literalKey.rawValue,
                              keyOrigin: literalKey.keyOrigin,
                              value: value)
  }
  
  @_disfavoredOverload
  public mutating func appendIfNotNil(_ value: (some ValueProtocol)?,
                                      forKey dynamicKey: String,
                                      duplicatePolicy: ValueDuplicatePolicy = .defaultForAppending) {
    guard let value else { return }
    _singleKeyValuePairAppend(key: dynamicKey,
                              keyOrigin: .dynamic,
                              value: value)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErrorInfo {
  internal mutating func _singleKeyValuePairAppend(key: String,
                                                   keyOrigin: KeyOrigin,
                                                   value: some ValueProtocol) {
    _add(key: key,
         keyOrigin: keyOrigin,
         value: value,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .defaultForAppending,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
}
