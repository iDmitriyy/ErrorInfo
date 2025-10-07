//
//  TypeInfoOptions.swift
//  ErrorInfo
//
//  Created by tmp on 07/10/2025.
//

public struct TypeInfoOptions: OptionSet, Sendable { // add tests
  public private(set) var rawValue: UInt32
  
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
  
  static let `default`: Self = [.nonBuiltIn]
  
  // MARK: Conditions
  
  /// To make possible explicitly specify `never` in source code.
  static let never = TypeInfoOptions([])
  
  /// Wrapped type of optional nil value.
  /// Imlicitly means `allTypes`, if more narrow category of types is not provided.
  static let whenNil = TypeInfoOptions(rawValue: 1 << 0)
  
  // MARK: Type categories
  
  /// All types without any exceptions.
  /// Implicitly means always, if option `whenNil` not passed.
  static let allTypes = TypeInfoOptions(rawValue: 1 << 2)
  
  /// Everything except primitives contained in standard library – bool, integers, floating point, String, StaticString
  /// Implicitly means always, if option `whenNil` not passed.
  static let nonPrimitive = TypeInfoOptions(rawValue: 1 << 3)
  
  /// Everything except primitives and standard library CustomStringConvertible builtin types: Colections, Ranges...
  /// The purpose is to add type information only for types defeined at user site – their classes or CustomStringConvertible types.
  /// Most of the values added to error info are typically form stndard library.
  /// The listed above types defined at user site tend be rarely added to error info and if it happens, then it might be good to be markered / handled.
  static let nonBuiltIn = TypeInfoOptions(rawValue: 1 << 4)
  
  /// Only Objects and Actors. Is a more narrow category than `nonPrimitive`
  /// Implicitly means always, if option `whenNil` not passed.
  static let onlyObjects = TypeInfoOptions(rawValue: 1 << 5)
}

extension TypeInfoOptions {
  
}
