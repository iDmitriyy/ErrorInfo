//
//  ErrorInfo+ValueVariant.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 24/11/2025.
//

// MARK: - _ValueVariant

extension ErrorInfo {
  internal struct _ValueVariant: Sendable, ApproximatelyEquatable {
    private let wrapped: Variant
    
    internal var optionalValue: (any ErrorInfoValueType)? {
      switch wrapped {
      case .value(let value): value
      case .nilInstance: nil
      }
    }
    
    internal var isValue: Bool {
      switch wrapped {
      case .value: true
      case .nilInstance: false
      }
    }
    
    internal var isNilInstance: Bool {
      switch wrapped {
      case .value: false
      case .nilInstance: true
      }
    }
    
    internal static func value(_ value: any ErrorInfoValueType) -> Self {
      Self(wrapped: .value(value))
    }
    
    internal static func nilInstance(typeOfWrapped: any Sendable.Type) -> Self { // FIXME: change Sendable.Type -> ErrorInfoValueType.Type
      // FIXME: `any Sendable.Type` & `(any Sendable).Type` is not the same. Explore this
      Self(wrapped: .nilInstance(typeOfWrapped: typeOfWrapped))
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs.wrapped, rhs.wrapped) {
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        ErrorInfoFuncs.isEqualEqatableExistential(a: lhsInstance, b: rhsInstance)
        
      case let (.nilInstance(lhsType), .nilInstance(rhsType)):
        lhsType == rhsType
      }
    }
    
    internal static func isApproximatelyEqual(lhs: borrowing Self, rhs: borrowing Self) -> Bool {
      switch (lhs.wrapped, rhs.wrapped) {
      case (.value, .nilInstance),
           (.nilInstance, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        ErrorInfoFuncs.isApproximatelyEqualAny(lhsInstance, rhsInstance)
        
      case let (.nilInstance(lhsType), .nilInstance(rhsType)):
        lhsType == rhsType
      }
    }
    
    private enum Variant {
      case value(any ErrorInfoValueType)
      case nilInstance(typeOfWrapped: any Sendable.Type)
    }
  }
}
