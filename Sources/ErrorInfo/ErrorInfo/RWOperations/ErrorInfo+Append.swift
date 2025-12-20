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
  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) {
    _add(key: dynamicKey,
         keyOrigin: .dynamic,
         value: newValue,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         collisionSource: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead
  }
  
  @available(*, deprecated, message: "for literal keys use subscript instead, append() is intended for dynamic keys)")
  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey literalKey: StringLiteralKey) {
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

// MARK: Append reflecting Any Value

extension ErrorInfo {
  // DEFERRED: imp
  // public mutating func append(key _: StringLiteralKey, reflectingValue newValue: (some Sendable)?) {
  //   if let newValue {
  //     // there can be nested optional here
  //   } else {
  //     // add nil with Wrapped type
  //   }
  // }
  
  public mutating func append(key literalKey: StringLiteralKey, reflectingValue newValue: (some Any)?) {
    _appendReflecting(anyValue: newValue, key: literalKey.rawValue, keyOrigin: literalKey.keyOrigin)
  }
  
  /// Appends a value by storing its reflective string representation.
  ///
  /// Use this overload when the value does not conform to
  /// `Sendable`, `Equatable`, or `CustomStringConvertible`, which are required
  /// for values stored directly in `ErrorInfo`.
  ///
  /// The value is converted using `String(reflecting:)`, and the resulting
  /// string is appended under the given key, allowing arbitrary values to be
  /// recorded without additional conformances.
  ///
  /// If `newValue` is `nil`, a `nil` entry is appended according to the
  /// current nil-preservation rules.
  ///
  /// - Parameters:
  ///   - dynamicKey: The key under which to store the reflected value.
  ///   - newValue: The value to reflect and append.
  ///
  /// ## Example
  /// ```swift
  /// struct NonConformingType { let id: Int }
  ///
  /// var info = ErrorInfo()
  /// info.append(key: "payload", reflectingValue: NonConformingType(id: 42))
  ///
  /// // Stores: "NonConformingType(id: 42)"
  /// ```
  @_disfavoredOverload
  public mutating func append(key dynamicKey: String, reflectingValue newValue: (some Any)?) {
    _appendReflecting(anyValue: newValue, key: dynamicKey, keyOrigin: .dynamic)
  }
  
  private mutating func _appendReflecting(anyValue newValue: (some Any)?,
                                          key: String,
                                          keyOrigin: KeyOrigin) {
    let debugDescr = newValue.map { String(reflecting: $0) }
    let optionalSecr = prettyDescriptionOfOptional(any: debugDescr) // TODO: extract wrapped type and append to nil
    _singleKeyValuePairAppend(key: key, keyOrigin: keyOrigin, value: optionalSecr, duplicatePolicy: .defaultForAppending)
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
