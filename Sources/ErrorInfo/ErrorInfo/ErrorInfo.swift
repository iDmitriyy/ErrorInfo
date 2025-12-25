//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

// TODO: !! add to doc that views are non-nil

/// An ordered key–value container for enriching errors with structured context.
///
/// ErrorInfo lets you attach human‑readable, thread‑safe values and then inspect
/// or merge that context later.
/// It’s designed as a replacement for ad‑hoc `[String: Any]` userInfo dictionaries,
/// with stronger guarantees.
///
/// Values must conform to `Sendable & Equatable & CustomStringConvertible`, ensuring:
/// - Meaningful textual representation for logs and diagnostics (`CustomStringConvertible`)
/// - Safe sharing across concurrency domains (`Sendable`)
/// - Predictable duplicate handling (`Equatable`)
///
/// ## Core features:
/// - No silent data loss from later writes by default: prior records remain available (use last/first/all views)
/// - Stable ordering: elements are iterated in insertion order, including values per key
/// - Duplicate handling policy for equal values (see ``ValueDuplicatePolicy``)
/// - Optional values: explicit `nil` entries are stored to signal presence, including the wrapped type
/// - Collision tracking, when the same key is written more than once (e.g. `onSubscript`, `onAppend`, `onMerge` ...)
/// - Append values to literal or dynamically formed keys
/// - Key origin metadata (where a key came from: literal, dynamic, keyPath, etc.)
/// - Merge multiple `ErrorInfo` instances without losing data and its provenance
///
/// ## Why multiple records per key:
/// Error context evolves across layers (networking, decoding, validation, retries, merges). Single‑slot key-value containers
/// silently lose history on overwrite or nil writes.
/// ErrorInfo keeps a time‑ordered trail under the same key so you can inspect how a value changed, choose the view
/// you need (last/first/all), and control deduplication via ``ValueDuplicatePolicy``.
///
/// `ErrorInfo` intentionally separates “removal” from explicitly or implicitly recorded `nil` so you don’t accidentally
/// lose a meaningful prior value.
/// Returning `nil` just because a later stage wrote a `nil` would reintroduce the classic “silent overwrite”
/// pitfall `ErrorInfo` is trying to avoid.
///
/// **Typical pitfalls solved**:
/// - Overwrite hides the root cause: keep a chain of records; read `.last` for the final state or `.first` for the earliest cause.
/// - `nil` wipes prior context: explicit `nil` is recorded (with wrapped type) without discarding earlier non‑nil entries.
/// - No provenance during merges: collisions are annotated with ``WriteProvenance`` so you can see where later writes came from.
/// - Duplicate spam: reject equal values with ``ValueDuplicatePolicy/rejectEqual`` while still admitting meaningful changes.
/// - Inconsistent key origins: ``KeyOrigin`` captures whether keys are literal, dynamic, keyPath, or transformed for clearer logs.
/// - Hard to debug ordering: iteration preserves insertion order for reproducible logs and testing.
///
/// ## See Also:
/// - ``ErrorInfoAny``: a non‑Sendable, type‑erased companion for bridging legacy `[String: Any]` APIs
/// - ``KeyOrigin``: describes where a key came from (string literal, keyPath etc.)
/// - ``WriteProvenance``: identifies how and where a key collision occurred (append, merge, sequence consumption, etc.)
///
/// # Example: Building and inspecting context
/// ```swift
/// var info = ErrorInfo()
/// info.appendValue(42, forKey: "user_id")
/// info.appendValue("checkout", forKey: .operation)
///
/// // Record an explicit nil to indicate a known‑missing value
/// info.appendValue(nil as String?, forKey: "promo_code")
///
/// // Append another value for the same key
/// info.appendValue("retry", forKey: .operation)
///
/// // Read back in insertion‑aware ways
/// let lastOperation = info[.operation]
/// // -> "retry"
///
/// let firstOperation = info.firstValue(forKey: .operation)
/// // -> "checkout"
///
/// let allOperations = info.allValues(forKey: .operation)
/// // -> ["checkout", "retry"]
///
/// // Scoped options and collision diagnostics:
///
/// let networkInfo = ErrorInfo.withOptions(duplicatePolicy: .rejectEqual) {
///   $0[.message] = "Timeout"
///   $0[.message] = "Timeout" // skipped by policy
///   $0[.attempts] = 3
/// }
///
/// // Merging retains provenance; collisions are annotated for inspection:
///
/// let summary = info.merged(with: networkInfo)
/// ```
public struct ErrorInfo: Sendable, ErrorInfoOperationsProtocol {
  @usableFromInline
  internal var _storage: ErrorInfoGeneric<KeyType, EquatableOptionalValue>
  
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

extension ErrorInfo {
  /// A single (key, value) pair element yielded during iteration.
  public typealias Element = (key: String, value: ValueExistential)
  
  /// The key type used by `ErrorInfo`.
  public typealias KeyType = String
  
  /// The existential used to store values that conform to ``ErrorInfo/ValueProtocol``.
  public typealias ValueExistential = any ValueProtocol
  
  /// `Sendable & Equatable & CustomStringConvertible`
  ///
  /// This approach addresses several important concerns:
  /// - **Thread Safety**: The `Sendable` requirement is essential to prevent data races and ensure safe concurrent access.
  /// - **String Representation**: Requiring `CustomStringConvertible` forces developers to provide values with meaningful string representations for stored values,
  ///   which is invaluable for debugging and logging. It also prevents unexpected results when converting values to strings.
  /// - **Collision Resolution**: The `Equatable` requirement allows to detect and potentially resolve collisions if different values are associated with the same key.
  ///   This adds a layer of robustness.
  public typealias ValueProtocol = Sendable & Equatable & CustomStringConvertible
  
  @usableFromInline
  internal typealias BackingStorage = ErrorInfoGeneric<KeyType, EquatableOptionalValue>
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Append KeyValue with all arguments passed explicitly

extension ErrorInfo {
  /// The root appending function for public API imps. The term "_add" is chosen to visually / syntatically differentiate from family of public `append()`functions.
  @usableFromInline
  internal mutating func _addDetachedValue<V: ValueProtocol>(_ newValue: V?,
                                                             shouldPreserveNilValues: Bool,
                                                             duplicatePolicy: ValueDuplicatePolicy,
                                                             forKey key: String,
                                                             keyOrigin: KeyOrigin,
                                                             writeProvenance: @autoclosure () -> WriteProvenance) {
    let optional: EquatableOptionalValue
    if let newValue {
      optional = .value(newValue)
    } else if shouldPreserveNilValues {
      optional = .nilInstance(typeOfWrapped: V.self)
    } else {
      return
    }
    
    _storage._addRecordWithCollisionAndDuplicateResolution(
      BackingStorage.Record(keyOrigin: keyOrigin, someValue: optional),
      forKey: key,
      duplicatePolicy: duplicatePolicy,
      writeProvenance: writeProvenance(),
    )
  }
  
  // SE-0352 Implicitly Opened Existentials
  // https://github.com/swiftlang/swift-evolution/blob/main/proposals/0352-implicit-open-existentials.md
  
  // SE-0375 Opening existential arguments to optional parameters
  
  /// Appends an explicit `nil` record preserving wrapped type.
  ///
  /// Use when the concrete value is not available but you need to record the presence of a `nil` entry
  /// (subject to `preserveNilValues`). The entry participates in collision tracking and ordering.
  ///
  /// - Parameters:
  ///   - key: The key to add.
  ///   - keyOrigin: The origin metadata for the key.
  ///   - duplicatePolicy: How to handle duplicates for subsequent non‑nil inserts.
  ///   - writeProvenance: The collision origin for diagnostics.
  internal mutating func _addNil(typeOfWrapped: any Sendable.Type,
                                 duplicatePolicy: ValueDuplicatePolicy,
                                 forKey key: String,
                                 keyOrigin: KeyOrigin,
                                 writeProvenance: @autoclosure () -> WriteProvenance) {
    let optional: EquatableOptionalValue = .nilInstance(typeOfWrapped: typeOfWrapped)
    
    _storage._addRecordWithCollisionAndDuplicateResolution(
      BackingStorage.Record(keyOrigin: keyOrigin, someValue: optional),
      forKey: key,
      duplicatePolicy: duplicatePolicy,
      writeProvenance: writeProvenance(),
    )
  }
}

// TODO: - add tests for elements ordering stability
// DEFERRED: - add overloads for Sendable AnyObjects & actors
