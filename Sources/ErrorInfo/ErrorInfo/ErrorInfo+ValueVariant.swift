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
    
    var optionalValue: (any ErrorInfoValueType)? {
      switch wrapped {
      case .value(let value): value
      case .typedNil: nil
      }
    }
    
    static func value(_ value: any ErrorInfoValueType) -> Self {
      Self(wrapped: .value(value))
    }
    
    static func nilInstance(typeOfWrapped: any Sendable.Type) -> Self { // FIXME: change Sendable.Type -> ErrorInfoValueType.Type
      // FIXME: `any Sendable.Type` & `(any Sendable).Type` is not the same. Explore this
      Self(wrapped: .typedNil(typeOfWrapped: typeOfWrapped))
    }
    
    static func isApproximatelyEqual(lhs: borrowing Self, rhs: borrowing Self) -> Bool {
      switch (lhs.wrapped, rhs.wrapped) {
      case (.value, .typedNil),
           (.typedNil, .value):
        false
        
      case let (.value(lhsInstance), .value(rhsInstance)):
        ErrorInfoFuncs.isApproximatelyEqualAny(lhsInstance, rhsInstance)
        
      case let (.typedNil(lhsType), .typedNil(rhsType)):
        lhsType == rhsType
      }
    }
    
    enum Variant {
      case value(any ErrorInfoValueType)
      case typedNil(typeOfWrapped: any Sendable.Type)
    }
  }
}
