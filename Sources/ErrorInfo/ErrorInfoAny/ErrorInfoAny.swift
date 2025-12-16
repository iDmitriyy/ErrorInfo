//
//  ErrorInfoAny.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

public struct ErrorInfoAny {
  public typealias KeyType = String
  public typealias ValueType = any Any
  
  internal typealias BackingStorage = ErrorInfoGeneric<String, EquatableAny>
  
  @usableFromInline internal var _storage: ErrorInfoGeneric<String, EquatableAny>
  
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
  @usableFromInline
  internal struct EquatableAny: Equatable, ErrorInfoOptionalRepresentable {
    public typealias TypeOfWrapped = any Any.Type
    
    let maybeValue: ErrorInfoOptionalAny
    
    private init(_unverifiedMaybeValue: ErrorInfoOptionalAny) {
      maybeValue = _unverifiedMaybeValue
    }
    
    init(anyValue: any Any) {
      self.maybeValue = ErrorInfoFuncs.flattenOptional(any: anyValue)
    }
    
    static func value(_ anyValue: Any) -> Self {
      Self(anyValue: anyValue)
    }
    
    static func nilInstance(typeOfWrapped: any Any.Type) -> Self {
      Self(_unverifiedMaybeValue: .nilInstance(typeOfWrapped: typeOfWrapped))
    }
    
    var isValue: Bool { maybeValue.isValue }
//    
    var getWrapped: Any? { maybeValue.getWrapped }
    
    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.maybeValue, rhs.maybeValue) {
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        "\(lhsInstance)" == "\(rhsInstance)" // FIXME: - Implement
        
      case let (.nilInstance(lhsType), .nilInstance(rhsType)):
        lhsType == rhsType
      }
    }
  }
}

public enum ErrorInfoOptionalAny: ErrorInfoOptionalRepresentable {
  case value(Any)
  case nilInstance(typeOfWrapped: any Any.Type)
  
  public typealias TypeOfWrapped = any Any.Type
  
  var isValue: Bool {
    switch self {
    case .value: true
    case .nilInstance: false
    }
  }
  
  var getWrapped: Any? {
    switch self {
    case .value(let value): value
    case .nilInstance: nil
    }
  }
}

// TypeEnhancedOptional
