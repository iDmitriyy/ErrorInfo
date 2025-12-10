//
//  Merge+Namespace.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 08/12/2025.
//

/// Namespacing
public enum Merge {}

/// Namespacing
extension Merge {
  public enum Format {}
}

extension Merge {
  /// Namespacing
  public enum DictUtils {}
}

extension Merge {
  /// Namespacing
  public enum Utils {}
}

extension Merge {
  /// Namespacing
  @usableFromInline internal enum Constants {}
}
