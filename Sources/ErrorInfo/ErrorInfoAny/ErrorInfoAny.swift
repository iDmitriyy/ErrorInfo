//
//  ErrorInfoAny.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

/// A non‑Sendable, type‑erased compatibility layer for legacy `[String: Any]` usage.
///
/// `ErrorInfoAny` is intended for codebases and modules that can’t yet adopt the strongly‑typed, `Sendable`
/// ``ErrorInfo``. It accepts heterogeneous values (`Any`) while mirroring many of ``ErrorInfo``’s capabilities:
/// - Preserves insertion order
/// - Tracks key origin and collision metadata (see ``KeyOrigin``)
/// - Honors duplicate‑value policies (see ``ValueDuplicatePolicy``)
/// - Supports multiple values per key
///
/// Prefer ``ErrorInfo`` whenever you can use `Sendable` types. Use `ErrorInfoAny` to bridge existing APIs that
/// exchange `[String: Any]` (e.g. legacy userInfo dictionaries) during incremental migration.
///
/// ## Optional handling
/// - Explicit `nil` entries are preserved together with a wrapped‑type of `Optional`.
/// - Nested optionals are flattened for consistent semantics.
///
/// ## Equality and duplicate policy with `Any`
/// Duplicate handling uses a best‑effort structural equality:
/// - Values that conform to `Equatable` are compared by value when possible.
/// - Non‑`Equatable` values are treated as non‑equal, so policies like ``ValueDuplicatePolicy/rejectEqual`` will keep
///   both entries.
/// - Nested optionals are flattened before comparison, so `Optional(Optional(x))` behaves like a single optional.
///
/// ## When to use
/// - Your module cannot adopt `Sendable` yet but you want the ordering, collision tracking, and duplicate‑handling
///   semantics provided by ``ErrorInfo``.
/// - You integrate with third‑party or legacy APIs that require.
///
/// ## Migration tips
/// - Keep boundaries narrow: convert to/from `[String: Any]` only at API edges.
/// - Start producing `ErrorInfoAny` internally, then down‑convert to `[String: Any]` when calling legacy APIs.
/// - Once your code becomes `Sendable`‑ready, switch to ``ErrorInfo``.
///
/// ## Example: Bridging at a legacy boundary
/// ```swift
/// func sendToLegacyAPI(_ info: ErrorInfoAny) {
///   let userInfo: [String: Any] = info.asDictionary()
///   legacyAPI.send(userInfo)
/// }
/// ```
public struct ErrorInfoAny: ErrorInfoOperationsProtocol {
  @usableFromInline internal var _storage: ErrorInfoGeneric<String, EquatableOptionalAny>
  
  // MARK: - Initializers
  
  private init(storage: BackingStorage) {
    _storage = storage
  }
  
  public init() {
    self.init(storage: BackingStorage())
  }
  
  public init(minimumCapacity: Int) {
    self.init(storage: BackingStorage(minimumCapacity: minimumCapacity))
  }
  
  public static var empty: Self { Self() }
}

extension ErrorInfoAny {
  public typealias Element = (key: String, value: Any)
  
  public typealias KeyType = String
  public typealias ValueExistential = Any
  
  @usableFromInline internal typealias BackingStorage = ErrorInfoGeneric<String, EquatableOptionalAny>
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append KeyValue with all arguments passed explicitly

extension ErrorInfoAny {
  /// The root appending function for public API imps. The term "_add" is chosen to visually / syntatically differentiate from family of public `append()`functions.
  @usableFromInline
  internal mutating func _add<V>(key: String,
                                 keyOrigin: KeyOrigin,
                                 value newValue: V?,
                                 preserveNilValues: Bool,
                                 duplicatePolicy: ValueDuplicatePolicy,
                                 writeProvenance: @autoclosure () -> WriteProvenance) {
    // FIXME: - unwrap / remove nesting of value / type
    // e.g. append(contentsOf sequence:)
    _storage._add(key: key,
                  keyOrigin: keyOrigin,
                  optionalValue: newValue,
                  typeOfWrapped: V.self,
                  preserveNilValues: preserveNilValues,
                  duplicatePolicy: duplicatePolicy,
                  writeProvenance: writeProvenance())
  }
}
