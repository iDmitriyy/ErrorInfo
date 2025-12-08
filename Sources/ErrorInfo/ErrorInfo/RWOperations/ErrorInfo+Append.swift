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
         keyOrigin: .dynamic,
         value: newValue,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         collisionSource: .onSubscript) // FIXME: .onSubscript source in append method.
    // How can we solve the propblem of namespace noise in subscript with dynamicKey?
    // May be it's ok to change collisionSource to .onAppend here
  }
  
  
  @available(*, deprecated, message: "for literal keys use subscript instead, append() is intended for dynamic keys)")
  public mutating func append(key literalKey: StringLiteralKey, value newValue: (some ValueType)?) {
    // deprecattion is used to guide users
    _add(key: literalKey.rawValue,
         keyOrigin: literalKey.keyOrigin,
         value: newValue,
         preserveNilValues: true,
         duplicatePolicy: .defaultForAppending,
         collisionSource: .onSubscript)
  }
}

// MARK: Append IfNotNil

extension ErrorInfo {
  public mutating func appendIfNotNil(_ value: (any ValueType)?,
                                      forKey literalKey: StringLiteralKey,
                                      duplicatePolicy: ValueDuplicatePolicy = .rejectEqual) {
    guard let value else { return }
    _appendWithDefaultTypeInfo(key: literalKey.rawValue,
                               keyOrigin: literalKey.keyOrigin,
                               value: value,
                               preserveNilValues: true, // has no effect in this func
                               duplicatePolicy: duplicatePolicy)
  }
  
  @_disfavoredOverload
  public mutating func appendIfNotNil(_ value: (any ValueType)?,
                                      forKey dynamicKey: String,
                                      duplicatePolicy: ValueDuplicatePolicy = .rejectEqual) {
    guard let value else { return }
    _appendWithDefaultTypeInfo(key: dynamicKey,
                               keyOrigin: .dynamic,
                               value: value,
                               preserveNilValues: true, // has no effect in this func
                               duplicatePolicy: duplicatePolicy)
  }
}

// MARK: Append ContentsOf

extension ErrorInfo {
  public mutating func append(contentsOf sequence: some Sequence<(String, any ValueType)>,
                              duplicatePolicy: ValueDuplicatePolicy) {
    for (dynamicKey, value) in sequence {
      _appendWithDefaultTypeInfo(key: dynamicKey,
                                 keyOrigin: .dynamic,
                                 value: value,
                                 preserveNilValues: true, // has no effect in this func
                                 duplicatePolicy: duplicatePolicy)
    }
  }
}

extension ErrorInfo {
  private mutating func _appendWithDefaultTypeInfo(key: String,
                                                   keyOrigin: KeyOrigin,
                                                   value: any ValueType,
                                                   preserveNilValues: Bool, // always true at call sites, need if value become optional
                                                   duplicatePolicy: ValueDuplicatePolicy) {
    _add(key: key,
         keyOrigin: keyOrigin,
         value: value,
         preserveNilValues: preserveNilValues,
         duplicatePolicy: duplicatePolicy,
         collisionSource: .onAppend)
  }
}
