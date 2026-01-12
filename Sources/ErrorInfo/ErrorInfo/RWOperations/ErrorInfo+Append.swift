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
    withCollisionAndDuplicateResolutionAdd(
      optionalValue: newValue,
      shouldPreserveNilValues: true,
      duplicatePolicy: .defaultForAppending,
      forKey: dynamicKey,
      keyOrigin: .dynamic,
      writeProvenance: .onAppend(origin: nil),
    ) // providing origin for a single key-value is an overhead for binary size
  }
  
  @available(*, deprecated, message: "for literal keys use subscript instead, append() is intended for dynamic keys)")
  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey literalKey: StringLiteralKey) {
    // deprecation is used to guide users
    withCollisionAndDuplicateResolutionAdd(
      optionalValue: newValue,
      shouldPreserveNilValues: true,
      duplicatePolicy: .defaultForAppending,
      forKey: literalKey.rawValue,
      keyOrigin: literalKey.keyOrigin,
      writeProvenance: .onAppend(origin: nil),
    ) // providing origin for a single key-value is an overhead for binary size
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: Append IfNotNil

extension ErrorInfo {
  public mutating func appendIfNotNil(_ value: (some ValueProtocol)?,
                                      forKey literalKey: StringLiteralKey) {
    guard let value else { return }
    _singleKeyValuePairAppend(key: literalKey.rawValue, keyOrigin: literalKey.keyOrigin, value: value)
  }
  
  @_disfavoredOverload
  public mutating func appendIfNotNil(_ value: (some ValueProtocol)?,
                                      forKey key: String) {
    guard let value else { return }
    _singleKeyValuePairAppend(key: key, keyOrigin: .dynamic, value: value)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErrorInfo {
  private mutating func _singleKeyValuePairAppend(key: String,
                                                  keyOrigin: KeyOrigin,
                                                  value: some ValueProtocol) {
    withCollisionAndDuplicateResolutionAdd(
      value: value,
      duplicatePolicy: .defaultForAppending,
      forKey: key,
      keyOrigin: keyOrigin,
      writeProvenance: .onAppend(origin: nil),
    ) // providing origin for a single key-value is an overhead for binary size
  } // inlining has no performance gain.
}
