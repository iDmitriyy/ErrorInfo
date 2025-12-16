//
//  ErrorInfoAny+Append.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//


/*
// MARK: - Append

extension ErrorInfoAny {
  /// Instead of subscript overload with `String` key to prevent pollution of autocomplete for `ErronInfoLiteralKey` by tons of String methods.
  @_disfavoredOverload
  public mutating func append(key dynamicKey: String, value newValue: (some ValueType)?) {
    _add(key: dynamicKey,
         keyOrigin: .dynamic,
         value: newValue,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         collisionSource: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead
  }
  
  @available(*, deprecated, message: "for literal keys use subscript instead, append() is intended for dynamic keys)")
  public mutating func append(key literalKey: StringLiteralKey, value newValue: (some ValueType)?) {
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

extension ErrorInfoAny {
  public mutating func appendIfNotNil(_ value: (any ValueType)?,
                                      forKey literalKey: StringLiteralKey,
                                      duplicatePolicy: ValueDuplicatePolicy = .rejectEqual) {
    guard let value else { return }
    _singleKeyValuePairAppend(key: literalKey.rawValue,
                              keyOrigin: literalKey.keyOrigin,
                              value: value,
                              duplicatePolicy: duplicatePolicy)
  }
  
  @_disfavoredOverload
  public mutating func appendIfNotNil(_ value: (any ValueType)?,
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

// MARK: Append ContentsOf

extension ErrorInfoAny {
  public mutating func append(contentsOf sequence: some Sequence<(String, any ValueType)>,
                              duplicatePolicy: ValueDuplicatePolicy,
                              collisionSource collisionOrigin: CollisionSource.Origin = .fileLine()) {
    for (dynamicKey, value) in sequence {
      _add(key: dynamicKey,
           keyOrigin: .dynamic,
           value: value,
           preserveNilValues: true, // has no effect here
           duplicatePolicy: duplicatePolicy,
           collisionSource: .onSequenceConsumption(origin: collisionOrigin))
    }
  }
}

extension ErrorInfoAny {
  internal mutating func _singleKeyValuePairAppend(key: String,
                                                   keyOrigin: KeyOrigin,
                                                   value: any ValueType,
                                                   duplicatePolicy: ValueDuplicatePolicy) {
    _add(key: key,
         keyOrigin: keyOrigin,
         value: value,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: duplicatePolicy,
         collisionSource: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead
  }
}
*/
