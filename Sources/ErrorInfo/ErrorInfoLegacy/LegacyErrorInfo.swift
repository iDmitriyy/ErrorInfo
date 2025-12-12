//
//  LegacyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16/09/2025.
//

public struct LegacyErrorInfo: IterableErrorInfo {
  public typealias Key = String
  public typealias Value = Any
  public typealias Element = (key: String, value: Any)
  
  typealias BackingStorage = KeyAugmentationErrorInfoGeneric<Dictionary<String, Any>>
  
  internal var _storage: BackingStorage
    
  private init(storage: BackingStorage) {
    _storage = storage
  }
  
  /// Creates an empty `ErrorInfo` instance.
  public init() {
    self.init(storage: BackingStorage())
  }
  
  /// Creates an empty `ErrorInfo` instance with a specified minimum capacity.
  public init(minimumCapacity: Int) {
    self.init(storage: BackingStorage(minimumCapacity: minimumCapacity))
  }
  
  /// An empty instance of `ErrorInfo`.
  public static var empty: Self { Self() }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - ___

extension LegacyErrorInfo {
  
}
