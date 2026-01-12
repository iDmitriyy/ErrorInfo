//
//  ErrorInfoAny+Append.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

// MARK: - Append

extension ErrorInfoAny {
  /// Instead of subscript overload with `String` key to prevent pollution of autocomplete for `StringLiteralKey` by tons of String methods.
  public mutating func append<T>(key dynamicKey: String, value newValue: T?) {
    _add(key: dynamicKey,
         keyOrigin: .dynamic,
         value: newValue,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
  
  @available(*, deprecated, message: "for literal keys use subscript instead, append() is intended for dynamic keys)")
  public mutating func append<T>(key literalKey: StringLiteralKey, value newValue: T?) {
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

extension ErrorInfoAny {
  public mutating func appendIfNotNil(_ value: (some Any)?,
                                      forKey literalKey: StringLiteralKey) {
    let flattenedOptional = ErrorInfoFuncs.flattenOptional(any: value)
    guard let value = flattenedOptional.getWrapped else { return }
    _add(key: literalKey.rawValue,
         keyOrigin: literalKey.keyOrigin,
         value: value,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .defaultForAppending,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
  
  @_disfavoredOverload
  public mutating func appendIfNotNil(_ value: (some Any)?,
                                      forKey key: String) {
    let flattenedOptional = ErrorInfoFuncs.flattenOptional(any: value)
    guard let value = flattenedOptional.getWrapped else { return }
    _add(key: key,
         keyOrigin: .dynamic,
         value: value,
         preserveNilValues: true, // has no effect in this func
         duplicatePolicy: .defaultForAppending,
         writeProvenance: .onAppend(origin: nil)) // providing origin for a single key-value is an overhead for binary size
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// extension ErrorInfoAny {
//  private mutating func _singleKeyValuePairAppend(key: String,
//                                                  keyOrigin: KeyOrigin,
//                                                  value: some ValueProtocol) {
//    withCollisionAndDuplicateResolutionAdd(
//      value: value,
//      duplicatePolicy: .defaultForAppending,
//      forKey: key,
//      keyOrigin: keyOrigin,
//      writeProvenance: .onAppend(origin: nil),
//    ) // providing origin for a single key-value is an overhead for binary size
//  } // inlining has no performance gain.
// }
