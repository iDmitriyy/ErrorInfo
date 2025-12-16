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
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
    
  // MARK: - All ForKey
  
  /// Returns all non-nil values associated with a given key in the `ErrorInfo` storage.
  ///
  /// This method retrieves all values associated with the specified key, returning them as a sequence.
  ///
  /// - Parameter literalKey: The key to look up in the `ErrorInfo` storage.
  ///
  /// - Returns: A non-empty sequence of values associated with the key, or `nil` if the key has no associated values.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  ///
  /// errorInfo[.id] = 5
  /// errorInfo[.id] = 6
  /// errorInfo[.id] = nil as Optional<String>
  ///
  /// // errorInfo.allValues(forKey: .id) // returns [5, 6]
  /// ```
  func allValues(forKey literalKey: StringLiteralKey) -> ValuesForKey<ValueType>?
  
  
  /// Returns all non-nil values associated with a given key in the `ErrorInfo` storage.
  ///
  /// This method retrieves all values associated with the specified key, returning them as a sequence.
  ///
  /// - Parameter dynamicKey: The key to look up in the `ErrorInfo` storage.
  ///
  /// - Returns: A non-empty sequence of values associated with the key, or `nil` if the key has no associated values.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  ///
  /// errorInfo["id"] = 5
  /// errorInfo["id"] = 6
  /// errorInfo["id"] = nil as Optional<String>
  ///
  /// // errorInfo.allValues(forKey: "id") // returns [5, 6]
  /// ```
  @_disfavoredOverload func allValues(forKey dynamicKey: String) -> ValuesForKey<ValueType>?
  
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - FirstLastForKey
  
  // MARK: Last For Key
  
  /// Returns the last non-nil value associated with the given literal key.
  ///
  /// - Returns: The last value associated with key, or `nil` if no value is found.
  ///
  /// # Example:
  /// ```swift
  /// var info = ErrorInfo()
  /// info[.id] = 5
  /// info[.id] = 6
  ///
  /// errorInfo.lastValue[forKey: .id) // returns 6
  /// ```
  func lastValue(forKey literalKey: StringLiteralKey) -> (ValueType)?
  
  @_disfavoredOverload func lastValue(forKey dynamicKey: String) -> (ValueType)?
  
  // MARK: First For Key
  
  /// Returns the first non-nil value associated with the given key.
  ///
  /// - Parameter literalKey: The key to look up in the `ErrorInfo` storage.
  ///
  /// - Returns: The first non-nil value associated with the key, or `nil` if no such value exists.
  ///
  /// # Example:
  /// ```swift
  /// var errorInfo = ErrorInfo()
  /// errorInfo[.id] = 5
  /// errorInfo[.id] = 6
  ///
  /// errorInfo.firstValue(forKey: .id) // returns 5
  /// ```
  func firstValue(forKey literalKey: StringLiteralKey) -> (ValueType)?
  
  @_disfavoredOverload func firstValue(forKey dynamicKey: String) -> (ValueType)?
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - KeyValue Lookup
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - RemoveAll
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - RemoveAll ForKey
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //
  
  // MARK: - ReplaceAll ForKey
}
