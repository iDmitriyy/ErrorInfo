//
//  ErrorInfoFunctions.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

//public import protocol IndependentDeclarations.DictionaryUnifyingProtocol
//private import FoundationExtensions

// MARK: - Merge ErrorInfo

/// Namespacing
public enum ErrorInfoFuncs {}

extension ErrorInfoFuncs {
  /// https://github.com/apple/swift-evolution/blob/main/proposals/0369-add-customdebugdescription-conformance-to-anykeypath.md
  internal static func asErrorInfoKeyString<R, V>(keyPath: KeyPath<R, V>) -> String {
    String(reflecting: keyPath)
  }
  
  internal static func typeDesciption(for value: some ErrorInfoValueType) -> String {
    let type = type(of: value)
    return "\(type)"
  }
  
  internal static func typeDesciption<T>(for type: T.Type) -> String {
    let type = type
    return "\(type)"
  }
  
  internal static func typeDesciptionIfNeeded(forOptional value: (any ErrorInfoValueType)?, options: TypeInfoOptions) -> String? {
    
  }
  
  internal static func typeDesciptionIfNeeded(for value: any ErrorInfoValueType,
                                              options: TypeInfoOptions) -> String? {
    guard !options.contains([.never, .whenNil]) else { return nil }
    
    switch options {
    case .never, .whenNil:
      return nil
      
    case .onlyObjects:
      return if type(of: value) is any AnyObject.Type {
        ErrorInfoFuncs.typeDesciption(for: value)
      } else {
        nil
      }
      
    case .nonBuiltIn:
      return if isOfBuiltinPrimitiveType(value: value) || isOfBuiltinNonPrimitiveType(value: value) {
        nil
      } else {
        ErrorInfoFuncs.typeDesciption(for: value)
      }
      
    case .nonPrimitive:
      return if isOfBuiltinPrimitiveType(value: value) {
        nil
      } else {
        ErrorInfoFuncs.typeDesciption(for: value)
      }
      
    default:
      return ErrorInfoFuncs.typeDesciption(for: value)
    }
  }
  
  private static func isOfBuiltinNonPrimitiveType(value: any ErrorInfoValueType) -> Bool {
    // TODO: proper implementation
    if type(of: value) is Array<Any>.Type {
      true
    } else if type(of: value) is Set<AnyHashable>.Type {
      true
    } else if type(of: value) is Dictionary<AnyHashable, Any>.Type {
      true
    } else if type(of: value) is any FloatingPoint.Type {
      true
    } else if value is any RangeExpression.Type { // FIXME: warning
      true
    } else {
      false
    }
  }
  
  private static func isOfBuiltinPrimitiveType(value: any ErrorInfoValueType) -> Bool {
    // Techically String is a collecion, not a primitive. However, specifying String type is redudant and meaningless in most cases.
    if type(of: value) is any StringProtocol.Type {
      true
    } else if type(of: value) is any BinaryInteger.Type {
      true
    } else if type(of: value) is Bool.Type {
      true
    } else if type(of: value) is any FloatingPoint.Type {
      true
    } else if value is StaticString { // FIXME: warning
      true
    } else {
      false
    }
  }
}
