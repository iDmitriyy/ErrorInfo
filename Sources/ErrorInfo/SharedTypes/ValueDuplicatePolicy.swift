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
/// ```swift
/// info.appendWith(duplicatePolicy: .allowEqual) {
///   $0["message"] = "Timeout" // from database
///   $0["message"] = "Timeout" // from network
/// }
/// ```
public struct ValueDuplicatePolicy: Sendable {
  @usableFromInline
  internal let kind: Kind
  
  private init(kind: Kind) {
    self.kind = kind
  }
  
  /// See ``ValueDuplicatePolicy.allowEqualWhenOriginDiffers``
  public static let defaultForAppending = allowEqualWhenOriginDiffers
  
  /// If the same value appended for th same key, it is typically a noise.
  /// KeyOrigin may ne differrent when creating from Dictionary Literal, so duplicate
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
