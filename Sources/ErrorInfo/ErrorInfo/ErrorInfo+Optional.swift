//
//  ErrorInfo+ValueVariant.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

extension ErrorInfo {
  @usableFromInline internal struct _Record: Sendable, ApproximatelyEquatable { // typeprivate
    @usableFromInline internal let _optional: OptionalWithTypedNil
    @usableFromInline internal let keyOrigin: KeyOrigin
    
    @usableFromInline
    static func isApproximatelyEqual(lhs: borrowing Self, rhs: borrowing Self) -> Bool {
      switch (lhs._optional.wrapped, rhs._optional.wrapped) {
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        ErrorInfoFuncs.isEqualAny(lhsInstance, rhsInstance)
        
      case let (.nilInstance(lhsType), .nilInstance(rhsType)):
        lhsType == rhsType
      }
    }
  }
  
  public struct OptionalWithTypedNil: Sendable, Equatable {
    @usableFromInline internal let wrapped: Variant
    
    public var optionalValue: (any ErrorInfoValueType)? {
      switch wrapped {
      case .value(let value): value
      case .nilInstance: nil
      }
    } // inlining has no effect on perfomance
    
    public var isValue: Bool {
      switch wrapped {
      case .value: true
      case .nilInstance: false
      }
    } // inlining has no effect on perfomance
    
    public var isNilInstance: Bool {
      switch wrapped {
      case .value: false
      case .nilInstance: true
      }
    } // inlining has no effect on perfomance
    
    internal static func value(_ value: any ErrorInfoValueType) -> Self {
      Self(wrapped: .value(value))
    }
    
    internal static func nilInstance(typeOfWrapped: any Sendable.Type) -> Self {
      Self(wrapped: .nilInstance(typeOfWrapped: typeOfWrapped))
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.wrapped, rhs.wrapped) {
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        ErrorInfoFuncs.isEqualEqatableExistential(a: lhsInstance, b: rhsInstance)
        
      case let (.nilInstance(lhsType), .nilInstance(rhsType)):
        lhsType == rhsType
      }
    } // inlining has 5% perfomance gain. Will not be called often in practice
    
    public enum Variant: Sendable {
      case value(any ErrorInfoValueType)
      case nilInstance(typeOfWrapped: any Sendable.Type)
    }
  }
}

// TBD: - add Custom(Debug)StringConvertible
