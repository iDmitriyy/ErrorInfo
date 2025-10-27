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
  /// Examples: "Foo.count", "count"
  /// https://github.com/apple/swift-evolution/blob/main/proposals/0369-add-customdebugdescription-conformance-to-anykeypath.md
  internal static func asErrorInfoKeyString<R, V>(keyPath: KeyPath<R, V>, withTypePrefix: Bool) -> String {
    let keyPathString = String(reflecting: keyPath) // e.g. "\Foo.count"
    
    if withTypePrefix {
      return String(keyPathString.dropFirst())
    } else {
      guard let dotIndex = keyPathString.firstIndex(of: ".") else { return keyPathString }
      let nextAfterDotIndex = keyPathString.index(after: dotIndex)
      return String(keyPathString[nextAfterDotIndex...])
    }
  }
}

extension ErrorInfoFuncs {
  @_disfavoredOverload
  public static func _typeDesciption(for optional: (any ErrorInfoValueType)?) {
    let typeOfWrapped = optional.typeOfWrapped()
    
    let typeOfWrappedStr = "\(typeOfWrapped)"
    print("___typeDescr:", typeOfWrappedStr)
    
    let dynamicOptType = type(of: optional)
    if let value = optional {
      print("___typeDescrDynamicOpt:", "\(dynamicOptType)")
      
      print("___typeDescrDynamicOptTWrapped:", "\(type(of: typeOfWrapped))")
      
      unpackExistential(value) { type in
        print("___typeDescrUnpacked:", "\(type)") // Int
      }
      
      let dynamicType = type(of: value)
      print("___typeDescrDynamic:", "\(dynamicType)") // Int
      
      _typeDesciptionG_Meta(for: typeOfWrapped)
    }
  }
  
  public static func _typeDesciption<T: ErrorInfoValueType>(for value: T?) {
    let typeOfWrapped = value.typeOfWrapped()
    
    let typeOfWrappedStr = "\(typeOfWrapped)"
    print("___typeDescrGeneric:", typeOfWrappedStr) // Int
  }
  
  public static func _typeDesciptionG_Meta<T>(for typeT: T.Type) {
    // print("___typeDescrGeneric_Meta:", "\(type)") // CustomStringConvertible & Equatable
    // print("___typeDescrGeneric_Meta:", "\(typeT.self)") // CustomStringConvertible & Equatable
    // print("___typeDescrGeneric_Meta:", "\(type(of: typeT))") // (CustomStringConvertible & Equatable).Protocol
    // print("___typeDescrGeneric_Meta:", "\(type(of: typeT.self))") // (CustomStringConvertible & Equatable).Protocol
    // print("___typeDescrGeneric_Meta:", "\(String(reflecting: typeT))") // Swift.CustomStringConvertible & Swift.Equatable
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
}
