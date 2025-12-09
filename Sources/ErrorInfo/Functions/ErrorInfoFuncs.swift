//
//  ErrorInfoFunctions.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

// public import protocol IndependentDeclarations.DictionaryUnifyingProtocol
// private import FoundationExtensions

// MARK: - Merge ErrorInfo

/// Namespacing
public enum ErrorInfoFuncs {}

extension ErrorInfoFuncs {
  /// Examples: "Foo.count", "count"
  
  /// Converts a KeyPath into a string representation for error reporting or debugging.
  ///
  /// If `withTypePrefix` is `true`, the result includes type and property name (e.g. `"Foo.count"`).
  ///
  /// If `false`, it returns just the property name, excluding the type (e.g. `"count"`).
  internal static func asErrorInfoKeyString<R, V>(keyPath: KeyPath<R, V>, withTypePrefix: Bool) -> String {
    let keyPathString = String(reflecting: keyPath) // e.g. "\Foo.count"
    if withTypePrefix {
      return String(keyPathString.dropFirst())
    } else {
      guard let dotIndex = keyPathString.firstIndex(of: ".") else { return keyPathString }
      let nextAfterDotIndex = keyPathString.index(after: dotIndex)
      
      // TODO: test for "\Foo." "" "."
      // guard nextAfterDotIndex < keyPathString.endIndex else { return keyPathString }
      
      return String(keyPathString[nextAfterDotIndex...])
    }
    /// https://github.com/apple/swift-evolution/blob/main/proposals/0369-add-customdebugdescription-conformance-to-anykeypath.md
  }
  
  /// Combines the file name and line number.
  /// - Returns: Example: `"File.swift:42"`
  internal static func fileLineString(file: StaticString, line: UInt) -> String {
    String(file) + ":\(line)"
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
  
  public static func _typeDesciption(for value: (some ErrorInfoValueType)?) {
    let typeOfWrapped = value.typeOfWrapped()
    
    let typeOfWrappedStr = "\(typeOfWrapped)"
    print("___typeDescrGeneric:", typeOfWrappedStr) // Int
  }
  
  public static func _typeDesciptionG_Meta<T>(for _: T.Type) {
    // print("___typeDescrGeneric_Meta:", "\(type)") // CustomStringConvertible & Equatable
    // print("___typeDescrGeneric_Meta:", "\(typeT.self)") // CustomStringConvertible & Equatable
    // print("___typeDescrGeneric_Meta:", "\(type(of: typeT))") // (CustomStringConvertible & Equatable).Protocol
    // print("___typeDescrGeneric_Meta:", "\(type(of: typeT.self))") // (CustomStringConvertible & Equatable).Protocol
    // print("___typeDescrGeneric_Meta:", "\(String(reflecting: typeT))") // Swift.CustomStringConvertible & Swift.Equatable
  }
  
  static func testt(ffe: any BinaryInteger) {
    testt(ffg: ffe)
  }
  
  static func testt(ffg _: some BinaryInteger) {}
  
  private static func unpackOptionalExistential<T: Equatable & Sendable>(_: T?, _ body: (T.Type) -> Void) {
    let typeOfWrapped = T.self
    body(typeOfWrapped)
  }
  
  private static func unpackExistential<T: ErrorInfoValueType>(_: T, _ body: (T.Type) -> Void) {
    let typeOfWrapped = T.self
    body(typeOfWrapped)
  }
}
