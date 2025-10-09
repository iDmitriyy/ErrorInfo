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
}

extension ErrorInfoFuncs {
  public static func _typeDesciption(for optional: (any ErrorInfoValueType)?) {
    let typeOfWrapped = optional.typeOfWrapped()
    
    let typeOfWrappedStr = "\(typeOfWrapped)"
    print("___typeDescr:", typeOfWrappedStr)
    
    let dynamicOptType = type(of: optional)
    if let value = optional {
      print("___typeDescrDynamicOpt:", "\(dynamicOptType)")
      
      unpackExistential(value) { type in
        print("___typeDescrUnpacked:", "\(type)")
      }
      
      let dynamicType = type(of: value)
      print("___typeDescrDynamic:", "\(dynamicType)")
      
    }
  }
  
  static func testt(ffe: any BinaryInteger) {
    testt(ffg: ffe)
  }
  
  static func testt<T: BinaryInteger>(ffg: T) {
    
  }
  
  private static func unpackOptionalExistential<T: Equatable & Sendable>(_ value: T?, _ body: (T.Type) -> Void) {
    let typeOfWrapped = T.self
    body(typeOfWrapped)
  }
  
  private static func unpackExistential<T: ErrorInfoValueType>(_ value: T, _ body: (T.Type) -> Void) {
    let typeOfWrapped = T.self
    body(typeOfWrapped)
  }
  
  public static func _typeDesciptionG<T: ErrorInfoValueType>(for value: T?) {
    let typeOfWrapped = value.typeOfWrapped()
    
    let typeOfWrappedStr = "\(typeOfWrapped)"
    print("___typeDescrGeneric:", typeOfWrappedStr)
  }
  
  internal static func typeDesciptionIfNeeded(forOptional value: (any ErrorInfoValueType)?,
                                              options: TypeInfoOptions) -> String? {
    let type = value.typeOfWrapped()
    return typeDesciptionIfNeeded(for: type, options: options, isOptionalWrapped: true)
  }
  
  internal static func typeDesciptionIfNeeded<T>(for value: T,
                                                 options: TypeInfoOptions) -> String? {
    typeDesciptionIfNeeded(for: T.self, options: options, isOptionalWrapped: false)
  }
  
  private static func typeDesciptionIfNeeded<T>(for type: T.Type,
                                                 options: TypeInfoOptions,
                                                 isOptionalWrapped: Bool) -> String? {
    guard !options.contains([.never, .whenNil]) else { return nil }
    
    switch options {
    case .never:
      return nil
    case .whenNil:
      return if isOptionalWrapped {
        ErrorInfoFuncs.typeDesciption(for: type)
      } else {
        nil
      }
    case .onlyObjects:
      return if type is any AnyObject.Type {
        ErrorInfoFuncs.typeDesciption(for: type)
      } else {
        nil
      }
      
    case .nonBuiltIn:
      return if isOfBuiltinPrimitiveType(value: type) || isOfBuiltinNonPrimitiveType(value: type) {
        nil
      } else {
        ErrorInfoFuncs.typeDesciption(for: type)
      }
      
    case .nonPrimitive:
      return if isOfBuiltinPrimitiveType(value: type) {
        nil
      } else {
        ErrorInfoFuncs.typeDesciption(for: type)
      }
      
    default:
      return ErrorInfoFuncs.typeDesciption(for: type)
    }
  }
  
  private static func typeDesciption<T>(for type: T.Type) -> String {
    let type = type
    return "\(type)"
  }
  
  private static func isOfBuiltinNonPrimitiveType<T>(value: T.Type) -> Bool {
    // TODO: proper implementation
    if value is Array<Any>.Type {
      true
    } else if value is Set<AnyHashable>.Type {
      true
    } else if value is Dictionary<AnyHashable, Any>.Type {
      true
    } else if value is any FloatingPoint.Type {
      true
    } else if value is any RangeExpression.Type { // FIXME: warning
      true
    } else {
      false
    }
  }
  
  private static func isOfBuiltinPrimitiveType<T>(value: T.Type) -> Bool {
    // Techically String is a collecion, not a primitive. However, specifying String type is redudant and meaningless in most cases.
    if value is any StringProtocol.Type {
      true
    } else if value is any BinaryInteger.Type {
      true
    } else if value is Bool.Type {
      true
    } else if value is any FloatingPoint.Type {
      true
    } else if value is StaticString.Type { // FIXME: warning
      true
    } else {
      false
    }
  }
}

extension Optional {
  fileprivate static func typeOfWrapped() -> Wrapped.Type { Wrapped.self }

  fileprivate func typeOfWrapped() -> Wrapped.Type { Wrapped.self }
}
