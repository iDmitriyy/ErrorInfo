//
//  ErrorInfo+AppendDescribing.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 21/12/2025.
//

// MARK: - Append describing

extension ErrorInfo {
  /// Appends the string produced by `String(describing:)` for the given value.
  public mutating func appendString(describing newValue: (some Sendable)?,
                                    forKey literalKey: StringLiteralKey) {
    _appendStringOfAnySendable(value: newValue,
                               key: literalKey.rawValue,
                               keyOrigin: literalKey.keyOrigin,
                               stringTransform: String.init(describing:))
  }
  
  @_disfavoredOverload
  public mutating func appendString(describing newValue: (some Sendable)?,
                                    forKey dynamicKey: String) {
    _appendStringOfAnySendable(value: newValue,
                               key: dynamicKey,
                               keyOrigin: .dynamic,
                               stringTransform: String.init(describing:))
  }
  
  public mutating func appendString(describing newValue: (some Any)?,
                                    forKey literalKey: StringLiteralKey) {
    _appendStringOfAny(value: newValue,
                       key: literalKey.rawValue,
                       keyOrigin: literalKey.keyOrigin,
                       stringTransform: String.init(describing:))
  }
  
  @_disfavoredOverload
  public mutating func appendString(describing newValue: (some Any)?,
                                    forKey dynamicKey: String) {
    _appendStringOfAny(value: newValue,
                       key: dynamicKey,
                       keyOrigin: .dynamic,
                       stringTransform: String.init(describing:))
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append reflecting Any Value

extension ErrorInfo {
  /// Appends the string produced by `String(reflecting:)` for the given value.
  public mutating func appendString(reflecting newValue: (some Sendable)?,
                                    forKey literalKey: StringLiteralKey) {
    _appendStringOfAnySendable(value: newValue,
                               key: literalKey.rawValue,
                               keyOrigin: literalKey.keyOrigin,
                               stringTransform: String.init(reflecting:))
  }
  
  @_disfavoredOverload
  public mutating func appendString(reflecting newValue: (some Sendable)?,
                                    forKey dynamicKey: String) {
    _appendStringOfAnySendable(value: newValue,
                               key: dynamicKey,
                               keyOrigin: .dynamic,
                               stringTransform: String.init(reflecting:))
  }
  
  public mutating func appendString(reflecting newValue: (some Any)?,
                                    forKey literalKey: StringLiteralKey) {
    _appendStringOfAny(value: newValue,
                       key: literalKey.rawValue,
                       keyOrigin: literalKey.keyOrigin,
                       stringTransform: String.init(reflecting:))
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
  /// If `newValue` is `nil`, a  string`"nil (Type)"` entry is appended.
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
  /// info.appendString(reflecting: NonConformingType(id: 42), forKey: "payload")
  /// // Stores: "NonConformingType(id: 42)"
  /// ```
  @_disfavoredOverload
  public mutating func appendString(reflecting newValue: (some Any)?, forKey dynamicKey: String) {
    _appendStringOfAny(value: newValue,
                       key: dynamicKey,
                       keyOrigin: .dynamic,
                       stringTransform: String.init(reflecting:))
  }
}

// MARK: - appendStringOf(Any)(Sendable) Imp

extension ErrorInfo {
  private mutating func _appendStringOfAny<T>(value newValue: T?,
                                              key: String,
                                              keyOrigin: KeyOrigin,
                                              stringTransform: (Any) -> String) {
    let stringRepresentation: String = switch ErrorInfoFuncs.flattenOptional(any: newValue) {
    case .value(let value): stringTransform(value)
    case .nilInstance(let typeOfWrapped): ErrorInfoFuncs.nilString(typeOfWrapped: typeOfWrapped)
      // TBD: ideally it is good to store explicit `nil` instance (case .nilInstance(typeOfWrapped:))
      // instead of nilDescription string.
      // However, this will require OptionalValue store `any Any.Type` instead of `any Sendable.Type` in case .nilInstance
    }
    
    withCollisionAndDuplicateResolutionAdd_inlined(
      value: stringRepresentation,
      duplicatePolicy: .defaultForAppending,
      forKey: key,
      keyOrigin: keyOrigin,
      writeProvenance: .onAppend(origin: nil),
    ) // providing origin for a single key-value is an overhead for binary size
  } // inlining has no performance gain.
  
  private mutating func _appendStringOfAnySendable(value newValue: (some Sendable)?,
                                                   key: String,
                                                   keyOrigin: KeyOrigin,
                                                   stringTransform: (any Sendable) -> String) {
    switch ErrorInfoFuncs.flattenOptional(anySendable: newValue) {
    case .left(let value):
      let stringRepresentation = stringTransform(value)
      withCollisionAndDuplicateResolutionAdd_inlined(
        value: stringRepresentation,
        duplicatePolicy: .defaultForAppending,
        forKey: key,
        keyOrigin: keyOrigin,
        writeProvenance: .onAppend(origin: nil),
      ) // providing origin for a single key-value is an overhead for binary size
      
    case .right(let typeOfWrapped):
      withCollisionAndDuplicateResolutionAddNilInstance(
        typeOfWrapped: typeOfWrapped,
        duplicatePolicy: .defaultForAppending,
        forKey: key,
        keyOrigin: keyOrigin,
        writeProvenance: .onAppend(origin: nil),
      ) // providing origin for a single key-value is an overhead for binary size
    }
  } // inlining has no performance gain.
}
