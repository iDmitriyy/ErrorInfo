//
//  ValueDuplicatePolicy.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 09/12/2025.
//

// MARK: - Value Duplicate Policy

extension ErrorInfo {
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
    internal let insertIfEqual: Bool
    
    private init(insertIfEqual: Bool) {
      self.insertIfEqual = insertIfEqual
    }
    
    public static let defaultForAppending = rejectEqual // => allowEqualWhenSourceDiffers
    
    /// Skip equal values
    public static let rejectEqual = Self(insertIfEqual: false)
    
    /// Store duplicates even when equal
    public static let allowEqual = Self(insertIfEqual: true)
    
    /// Keep duplicates only when keyOrigin or collisionSource differs
    // static let allowEqualWhenSourceDiffers
        
    /// Custom decision logic
    // static func custom((_ existing: Entry, _ new: Entry) -> Bool)
    
    // Already rejected options:
    // - DuplicatePolicy for nil values should be the same as for values and regulated by preserveNilValues
    // - updateCurrentByNew – effectively is a .replaceAllValues(forKey:, by:).
  }
}
