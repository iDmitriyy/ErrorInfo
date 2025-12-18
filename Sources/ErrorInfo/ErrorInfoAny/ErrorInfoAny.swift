//
//  ErrorInfoAny.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 13/12/2025.
//

public struct ErrorInfoAny: ErrorInfoOperationsProtocol {
  public typealias Element = (key: String, value: Any)
  
  public typealias Key = String
  public typealias ValueExistential = any Any
  
  internal typealias BackingStorage = ErrorInfoGeneric<String, EquatableOptionalAny>
  
  @usableFromInline internal var _storage: ErrorInfoGeneric<String, EquatableOptionalAny>
  
  // MARK: - Initializers
  
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
  internal mutating func _add<V>(key: String,
                                 keyOrigin: KeyOrigin,
                                 value newValue: V?,
                                 preserveNilValues: Bool,
                                 duplicatePolicy: ValueDuplicatePolicy,
                                 collisionSource: @autoclosure () -> CollisionSource) {
    // FIXME: - unwrap / remove nesting of value / type
    // e.g. append(contentsOf sequence:)
    _storage._add(key: key,
                  keyOrigin: keyOrigin,
                  optionalValue: newValue,
                  typeOfWrapped: V.self,
                  preserveNilValues: preserveNilValues,
                  duplicatePolicy: duplicatePolicy,
                  collisionSource: collisionSource())
  }
}

extension ErrorInfoAny {
  @usableFromInline
  internal struct EquatableOptionalAny: Equatable, ErrorInfoOptionalRepresentable {
    typealias Wrapped = Any
    typealias TypeOfWrapped = any Any.Type
    
    let maybeValue: ErrorInfoOptionalAny
    
    private init(_unverifiedMaybeValue: ErrorInfoOptionalAny) {
      maybeValue = _unverifiedMaybeValue
    }
    
    init(anyValue: any Any) {
      maybeValue = ErrorInfoFuncs.flattenOptional(any: anyValue)
    }
    
    static func value(_ anyValue: Any) -> Self {
      Self(anyValue: anyValue)
    }
    
    static func nilInstance(typeOfWrapped: any Any.Type) -> Self {
      // FIXME: - type can be incorrect, extract root type
      Self(_unverifiedMaybeValue: .nilInstance(typeOfWrapped: typeOfWrapped))
    }
    
    var isValue: Bool { maybeValue.isValue }
    
    var getWrapped: Any? { maybeValue.getWrapped }
    
    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.maybeValue, rhs.maybeValue) {
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        // As `Any` instances are flattened in EquatableOptionalAny's initializer, call
        // _isEqualFlattenedExistentialAnyWithUnboxing func.
        ErrorInfoFuncs.__PrivateImps._isEqualFlattenedExistentialAnyWithUnboxing(a: lhsInstance, b: rhsInstance)
        
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
