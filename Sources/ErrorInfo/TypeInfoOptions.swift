//
//  TypeInfoOptions.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 07/10/2025.
//

public struct TypeInfoOptions: OptionSet, Sendable { // add tests
  public private(set) var rawValue: UInt32
  
  public init(rawValue: UInt32) {
    self.rawValue = rawValue
  }
  
  /// alias to `.nonBuiltIn` option
  internal static let `default`: Self = .nonBuiltIn
  
  // MARK: Conditions
  
  /// To make possible explicitly specify `never` in source code.
  ///
  /// If chosen, any oher options are ignore.
  public static let never = TypeInfoOptions([])
  
  /// Wrapped type of optional nil value.
  /// Imlicitly means `allTypes`, if more narrow category of types is not provided.
  public static let whenNil = TypeInfoOptions(rawValue: 1 << 0)
  
  // TODO: How to express the ideaa when someone wants
  // 1) nonBuiltIn for non-optional values.
  // In common case, for standard types like Dict / Array the string repesentation is recognizable and obvious.
  // But if a custom type was passed, it is good to have an ability to extract the type of passed value.
  // 2) all types when it is nil. If there several nil values passed as optionals with different Wrapped types,
  // it may be good to know that.
  
  // MARK: Type categories
  
  /// All types without any exceptions.
  /// Implicitly means \`always\`, if option \`whenNil\` not passed.
  public static let allTypes = TypeInfoOptions(rawValue: 1 << 2)
  
  /// Everything except primitives contained in standard library – bool, integers, floating point, String, StaticString
  ///
  /// Implicitly means \`always\`, if option \`whenNil\` not passed.
  public static let nonPrimitive = TypeInfoOptions(rawValue: 1 << 3)
  
  /// Everything except primitives and standard library CustomStringConvertible builtin types: Colections, Ranges...
  ///
  /// Implicitly means \`always\`, if option \`whenNil\` not passed.
  ///
  /// The purpose is to add type information only for types defeined at user site – their classes or CustomStringConvertible types.
  /// Most of the values added to errorInfo are typically form stndard library.
  /// The listed above types defined at user site tend be rarely added to errorInfo and if it happens, then it might be good to be markered / handled.
  ///
  /// Another rationale is specifyng Int, Float, String and similar types makes noise and is practically meamingless / useless in general case.
  public static let nonBuiltIn = TypeInfoOptions(rawValue: 1 << 4)
  
  /// Only Objects and Actors. Is a more narrow category than `nonPrimitive`
  ///
  /// Implicitly means \`always\`, if option \`whenNil\` not passed.
  public static let onlyObjects = TypeInfoOptions(rawValue: 1 << 5)
}
