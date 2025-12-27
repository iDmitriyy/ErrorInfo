//
//  ValueDuplicatePolicy.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 09/12/2025.
//

// MARK: - Value Duplicate Policy

/// This policy dictates how duplicate values are handled when inserting into an `ErrorInfo`.
///
/// It is particularly useful when:
/// - Equal values represent different events. e.g. when the fact of having 2 equal values by itself is a useful signal.
/// - You need to track how often a specific value appears, or count occurrences of specific codes.
/// - Different origins (such as database and network) should be tracked even if the values are the same.
///
/// # Example
/// ```swift
/// info.appendWith(duplicatePolicy: .allowEqual) {
///   $0[.message] = nitification.message
///   // key == "message"
///
///   $0[dynamicKey: response.key] = payload.description
///   // key == "message"
/// }
/// ```
///
/// # DuplicatePolicy overview
///
/// - ## Single Key-Value append family functions, including subscript
///   `keyOrigin` can vary, and `WriteProvenance.Origin` is the same for operation type,
///   e.g. all writes via `subscript[]` will have the same `WriteProvenance.Origin`.
///
///   **duplicates saved only if keyOrigin differs**.
///
///   First value has no collision source, so insertion of equal `key-value` pair (e.g. via subscript)
///   is effectively done when `keyOrigin` differs.
///
///   > **Rationale:**
///   > - when there is a first value and another one (equal) is added, different `keyOrigin` typically
///     means they are from different sources of data.
///     Example: already stored `keyOrigin` is `literal`, and new one is `dynamic`, so keep them both.
///   > - when a third and all next (equal) values is added (extremely rare in practice), econd value already
///     have `collisionSource`, but it is the same as `WriteProvenance.Origin`
///     of redudant subscript.
///     So it is added if `keyOrigin` differs.
///     **! current imp, handle case when and keyOrigin literal & commbinedLiteral are treated the same**
///
/// - ## DictionaryLiteral init
///   keyOrigin and writePrvenance constants
///
///   As it is init, there are no values already stored in errorInfo, so collisions/duplicated values occur within the literal itself.
///
///   **duplicates saved**
///   > **Rationale:**
///   init from literal is made by explicitly defined keys. If duplications happens this is a
///   mistake (in a cocntrolled code) that should be visible and resolved, if happens. Extremly rare in practice.
///   **! current imp can be used, need to explictly pass .allowEqual**
///
/// - ## Append Key-Values from dictionaryLiteral
///     KeyOrigin is constant, and `WriteProvenance.Origin` is the same for all operations in scope.
///      > duplicates
/// defaultForAppending(`allowEqualWhenOriginDiffers`)
///
/// - ## Append with options scope
///     `keyOrigin` can vary, and `WriteProvenance.Origin` is the same for all operations in scope.
///     Duplicate policy specified for all write opertions in scope, and
///     can be defined individually for concrete operation.
///
/// - ## AppendProperties from keyPaths
///     KeyOrigin is constant, and `WriteProvenance.Origin` is the same for all operations in scope.
///
///   All key-values are added from the same object, so collisions are a mistake / niose, created by repetitive add
///   from the same keyPath.
///
/// - ## Append contents of sequence
///
/// - ## Merge
///   Merge preserve all information by design (duplicatePolicy `allowEqual` used internally).
///   Duplicate and `nil` values are preserved, collision source annotations are added as is.
///
///   > **Rationale:**
///   Merge operation is intentionally designed for merging several error info instances without data loss.
///   All content innside instances is treated important and was already processed by another write operations.
///   Despite collisions occurs only sometimes, it is imprtant to know when they actually happen, so any
///   kind of filtering inside `merge(Self...)` operations family is as loss of data and would be harmful for
///   further inspection.
public struct ValueDuplicatePolicy: Sendable, CustomDebugStringConvertible {
  @usableFromInline
  internal let kind: Kind
  
  private init(kind: Kind) {
    self.kind = kind
  }
  
  public var debugDescription: String {
    switch kind {
    case .rejectEqualValue: "rejectEqual"
    case .rejectEqualValueWhenEqualOrigin: "rejectEqualWithSameOrigin"
    case .allowEqual: "allowEqual"
    }
  }
  
  /// See ``ValueDuplicatePolicy.allowEqualWhenOriginDiffers``
  public static let defaultForAppending = allowEqualWhenOriginDiffers
  
  /// If the same value appended for th same key, it is typically a noise.
  /// KeyOrigin may be different when creating from Dictionary Literal, so duplicate
  /// CollisionOrigin 
  public static let defaultForAppendingDictionaryLiteral = allowEqualWhenOriginDiffers
  
  /// - `.rejectEqual`:
  /// - `.allowEqualWhenOriginDiffers`:
  
  /// Skip insertion if any existing value for `key` has an equal `record.someValue`. Otherwise append.
  public static let rejectEqual = Self(kind: .rejectEqualValue)
  
  /// Always append without comparing to existing values.
  public static let allowEqual = Self(kind: .allowEqual)
  
  /// Skip insertion only when an existing value for `key` matches all of the following:
  /// - the same `value`
  /// - the same `keyOrigin`
  /// - and, when present, the same `collisionSource`. If an existing record
  ///   has no `collisionSource`, this dimension is ignored.
  ///   Otherwise, the new record is appended.
  public static let allowEqualWhenOriginDiffers = Self(kind: .rejectEqualValueWhenEqualOrigin)
  public static let rejectEqualWithSameOrigin = Self(kind: .rejectEqualValueWhenEqualOrigin)
      
  /// Custom decision logic
  // static func custom((_ existing: FullInfoRecord, _ new: FullInfoRecord) -> Bool)
  
  // Already rejected options:
  // - DuplicatePolicy for nil values should be the same as for values and regulated by preserveNilValues
  // - updateCurrentByNew – effectively is a .replaceAllValues(forKey:, by:).
  
  @usableFromInline internal enum Kind: Sendable {
    case rejectEqualValue
    case rejectEqualValueWhenEqualOrigin
    case allowEqual
  }
}
