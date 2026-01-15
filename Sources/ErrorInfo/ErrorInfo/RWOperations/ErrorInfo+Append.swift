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
  @inlinable @inline(__always)
  public mutating func appendValue(_ newValue: consuming (some ValueProtocol)?, forKey dynamicKey: consuming String) { // 85.709
    _appendValue_imp(.fromOptional(newValue), forKey: dynamicKey, keyOrigin: .dynamic)
  }
  
  @available(*, deprecated, message: "for literal keys use subscript instead, appendValue(_:) is intended for dynamic keys)")
  @inlinable @inline(__always)
  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey literalKey: StringLiteralKey) {
    // deprecation is used to guide users
    _appendValue_imp(.fromOptional(newValue), forKey: literalKey.rawValue, keyOrigin: literalKey.keyOrigin)
  }
  
//  @_disfavoredOverload
//  public mutating func appendValue(_ newValue: ValueExistential, forKey dynamicKey: String) { // 3.6
//    blackHole(OptionalValue.value(newValue))
//  }
  
//  @_disfavoredOverload
//  public mutating func appendValue(_ newValue: ValueExistential, forKey dynamicKey: String) { // 63
//    blackHole(OptionalValue.fromOptional(newValue))
//  }
  
//  @_disfavoredOverload
//  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) { // 41
//    blackHole(OptionalValue.fromOptional(newValue))
//  }
  
//  @_disfavoredOverload
//  @inlinable @inline(__always)
//  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey _: String) { // 1.7
//    blackHole(OptionalValue.fromOptional(newValue))
//  }
  
//  @_disfavoredOverload
//  public mutating func appendValue(_ newValue: ValueExistential, forKey dynamicKey: String) { // 85.9
//    _storage.withCollisionAndDuplicateResolutionAdd(
//      record: BackingStorage.Record(keyOrigin: .dynamic, someValue: .value(newValue)),
//      forKey: dynamicKey,
//      duplicatePolicy: .defaultForAppending,
//      writeProvenance: .onAppend(origin: nil),
//    )
//  }
  
//   @inlinable @inline(__always)
//   @_disfavoredOverload
//   public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) { // 91
//     withCollisionAndDuplicateResolutionAdd(
//       optionalInstance: .fromOptional(newValue),
//       duplicatePolicy: .defaultForAppending,
//       forKey: dynamicKey,
//       keyOrigin: .dynamic,
//       writeProvenance: .onAppend(origin: nil),
//     ) // providing origin for a single key-value is an overhead for binary size
//   }
  
//  @_disfavoredOverload
//  public mutating func appendValue(_ newValue: (some ValueProtocol)?, forKey dynamicKey: String) { // 119.9 | 133
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
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: Append IfNotNil

extension ErrorInfo {
  @inlinable @inline(__always)
  public mutating func appendIfNotNil(_ value: (some ValueProtocol)?,
                                      forKey literalKey: StringLiteralKey) {
    guard let value else { return }
    _appendValue_imp(.value(value), forKey: literalKey.rawValue, keyOrigin: literalKey.keyOrigin)
  }
  
  @_disfavoredOverload
  @inlinable @inline(__always)
  public mutating func appendIfNotNil(_ value: consuming (some ValueProtocol)?,
                                      forKey key: consuming String) { // optimized
    switch consume value {
    case .some(let value):
      _appendValue_imp(.value(value), forKey: key, keyOrigin: .dynamic)
    case .none:
      break
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension ErrorInfo {
  @usableFromInline
  internal mutating func _appendValue_imp(_ value: consuming OptionalValue,
                                          forKey key: consuming String,
                                          keyOrigin: consuming KeyOrigin) {
    _storage.withCollisionAndDuplicateResolutionAdd(
      record: BackingStorage.Record(keyOrigin: keyOrigin, someValue: .init(instanceOfOptional: value)),
      forKey: key,
      duplicatePolicy: .defaultForAppending,
      writeProvenance: .onAppend(origin: nil), // providing origin for a single key-value is an overhead for binary size
    )
  }
}
