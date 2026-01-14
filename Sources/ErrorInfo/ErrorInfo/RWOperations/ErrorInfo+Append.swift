//
//  ErrorInfo+Append.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Append

extension ErrorInfo {
  /// Instead of subscript overload with `String` key to prevent pollution of autocomplete for `StringLiteralKey` by tons of String methods.
  
   @inlinable @inline(__always)
   @_disfavoredOverload
   public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) { // 79
     withCollisionAndDuplicateResolutionAdd(
       optionalInstance: .fromOptional(newValue),
       duplicatePolicy: .defaultForAppending,
       forKey: dynamicKey,
       keyOrigin: .dynamic,
       writeProvenance: .onAppend(origin: nil),
     ) // providing origin for a single key-value is an overhead for binary size
   }
  
//  @_disfavoredOverload
//  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) { // 119.9
//    withCollisionAndDuplicateResolutionAdd_inlined(
//      optionalInstance: .fromOptional(newValue),
//      duplicatePolicy: .defaultForAppending,
//      forKey: dynamicKey,
//      keyOrigin: .dynamic,
//      writeProvenance: .onAppend(origin: nil),
//    ) // providing origin for a single key-value is an overhead for binary size
//  }
  
//  @_disfavoredOverload
//  public mutating func appendValue<V: ValueProtocol>(_ newValue: V?, forKey dynamicKey: String) {
//    if let newValue {
//      withCollisionAndDuplicateResolutionAdd( // 132 | _inlined: 132
//        value: newValue,
//        duplicatePolicy: .defaultForAppending,
//        forKey: dynamicKey,
//        keyOrigin: .dynamic,
//        writeProvenance: .onAppend(origin: nil),
//      ) // providing origin for a single key-value is an overhead for binary size
//    } else {
//      withCollisionAndDuplicateResolutionAddNilInstance(typeOfWrapped: V.self, // 114 | inlined 116
//                                                        duplicatePolicy: .defaultForAppending,
//                                                        forKey: dynamicKey,
//                                                        keyOrigin: .dynamic,
//                                                        writeProvenance: .onAppend(origin: nil))
//    }
//  }
  
  // @_disfavoredOverload
  // public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) { // 140
  //   withCollisionAndDuplicateResolutionAdd( // _inlined has same perf
  //     optionalValue: newValue,
  //     shouldPreserveNilValues: true,
  //     duplicatePolicy: .defaultForAppending,
  //     forKey: dynamicKey,
  //     keyOrigin: .dynamic,
  //     writeProvenance: .onAppend(origin: nil),
  //   ) // providing origin for a single key-value is an overhead for binary size
  // }
  
  // @_disfavoredOverload
  // public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) { // 140
  //   withCollisionAndDuplicateResolutionAdd_inlined(
  //     optionalInstance: .fromOptional(newValue),
  //     shouldPreserveNilValues: true,
  //     duplicatePolicy: .defaultForAppending,
  //     forKey: dynamicKey,
  //     keyOrigin: .dynamic,
  //     writeProvenance: .onAppend(origin: nil),
  //   ) // providing origin for a single key-value is an overhead for binary size
  // }
  
  // @inlinable @inline(__always)
  // @_disfavoredOverload
  // public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) { // 104.875
  //   withCollisionAndDuplicateResolutionAdd(
  //     optionalInstance: .fromOptional(newValue),
  //     shouldPreserveNilValues: true,
  //     duplicatePolicy: .defaultForAppending,
  //     forKey: dynamicKey,
  //     keyOrigin: .dynamic,
  //     writeProvenance: .onAppend(origin: nil),
  //   ) // providing origin for a single key-value is an overhead for binary size
  // }
  
  @available(*, deprecated, message: "for literal keys use subscript instead, append() is intended for dynamic keys)")
  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey literalKey: StringLiteralKey) {
    // deprecation is used to guide users
    withCollisionAndDuplicateResolutionAdd(
      optionalInstance: .fromOptional(newValue),
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
  @inlinable @inline(__always)
  public mutating func appendIfNotNil(_ value: (some ValueProtocol)?,
                                      forKey key: String) {
//    guard let value else { return }
//    _singleKeyValuePairAppend(key: key, keyOrigin: .dynamic, value: value)
    withCollisionAndDuplicateResolutionAdd(
      optionalInstance: .fromOptional(value),
      shouldPreserveNilValues: false,
      duplicatePolicy: .defaultForAppending,
      forKey: key,
      keyOrigin: .dynamic,
      writeProvenance: .onAppend(origin: nil),
    ) // providing origin for a single key-value is an overhead for binary size
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErrorInfo {
  @inlinable @inline(__always)
  internal mutating func _singleKeyValuePairAppend(key: String,
                                                   keyOrigin: KeyOrigin,
                                                   value: some ValueProtocol) {
    withCollisionAndDuplicateResolutionAdd_inlined(
      value: value,
      duplicatePolicy: .defaultForAppending,
      forKey: key,
      keyOrigin: keyOrigin,
      writeProvenance: .onAppend(origin: nil),
    ) // providing origin for a single key-value is an overhead for binary size
  } // inlining has no performance gain.
}
