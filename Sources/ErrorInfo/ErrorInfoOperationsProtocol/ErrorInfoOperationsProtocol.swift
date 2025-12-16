//
//  ErrorInfoOperationsProtocol.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

/// Protocol defines all methods for
/// Keeps documentation for common methods.
public protocol ErrorInfoOperationsProtocol {
  associatedtype ValueType
  associatedtype KeyType
  
  /// Creates an empty `ErrorInfo` instance.
  init()
  
  /// Creates an empty `ErrorInfo` instance with a specified minimum capacity.
  init(minimumCapacity: Int)
  
  /// An empty instance of `ErrorInfo`.
  static var empty: Self { get }
}
