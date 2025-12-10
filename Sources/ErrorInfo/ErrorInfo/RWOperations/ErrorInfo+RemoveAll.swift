//
//  ErrorInfo+RemoveAll.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Remove All

extension ErrorInfo {
  /// Removes all key-value pairs from the storage, optionally keeping its capacity.
  ///
  /// - Parameter keepCapacity: Pass `true` to keep the existing capacity of
  ///   the errorInfo after removing its records. The default value is `false`.
  ///
  /// - Complexity: O(*n*), where *n* is the count of all records.
  internal mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _storage.removeAll(keepingCapacity: keepCapacity)
  }
}
