//
//  ErrorInfo+ValueVariant.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - Optional

extension ErrorInfo {
  @usableFromInline internal struct EquatableOptionalAnyValue: Sendable, Equatable, ErrorInfoOptionalRepresentable {
    @usableFromInline internal let maybeValue: OptionalAnyValue
    
    internal static func value(_ value: any ErrorInfoValueType) -> Self {
      Self(maybeValue: .value(value))
    }
    
    internal static func nilInstance(typeOfWrapped: any Sendable.Type) -> Self {
      Self(maybeValue: .nilInstance(typeOfWrapped: typeOfWrapped))
    }
    
    @usableFromInline var getWrapped: (ValueType)? { maybeValue.getWrapped }
    
    var isValue: Bool { maybeValue.isValue }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.maybeValue, rhs.maybeValue) {
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        ErrorInfoFuncs.isEqualEqatableExistential(a: lhsInstance, b: rhsInstance)
        
      case let (.nilInstance(lhsType), .nilInstance(rhsType)):
        lhsType == rhsType
      }
    } // inlining has 5% perfomance gain. Will not be called often in practice
  }
}

// MARK: - MaybeValue

extension ErrorInfo {
  public enum OptionalAnyValue: Sendable {
    case value(any ErrorInfoValueType)
    case nilInstance(typeOfWrapped: any Sendable.Type)
    
    public var getWrapped: ValueType? {
      switch self {
      case .value(let value): value
      case .nilInstance: nil
      }
    } // inlining has no effect on perfomance
    
    public var isValue: Bool {
      switch self {
      case .value: true
      case .nilInstance: false
      }
    } // inlining has no effect on perfomance
    
    public var isNil: Bool {
      switch self {
      case .value: false
      case .nilInstance: true
      }
    } // inlining has no effect on perfomance
  }
}

// TBD: - add Custom(Debug)StringConvertible
