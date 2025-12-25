//
//  WriteProvenance.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 03/10/2025.
//

/// Represents different sources of key collisions in the context of error information.
///
/// `WriteProvenance` is used to track where and how a key collision occurs. This helps in identifying the context
/// in which the collision happens, whether it's due to a specific operation like subscript access, appending,
/// merging, or due to specific transformations like adding prefixes or suffixes.
///
/// ## Cases:
/// - `onSubscript`: Indicates a collision during subscript access. An optional `Origin` can provide additional context.
/// - `onAppend`: Indicates a collision during an append operation. An optional `Origin` can provide additional context.
/// - `onMerge`: Indicates a collision during a merge operation, with the associated `Origin`.
/// - `onAddPrefix`: Indicates a collision when a prefix is added to the key. The prefix is provided as a string.
/// - `onAddSuffix`: Indicates a collision when a suffix is added to the key. The suffix is provided as a string.
/// - `onKeysMapping`: Indicates a collision due to a key mapping operation. It includes both the original and mapped keys.
/// - `onCreateWithDictionaryLiteral`: Indicates a collision that occurred when creating an `ErrorInfo` from a dictionary literal.
/// - `onDictionaryLiteralConsumption`: Indicates a collision that occurred during the consumption of a dictionary literal by `ErrorInfo`.
/// - `onDictionaryConsumption`: Indicates a collision that occurred during the consumption of a dictionary by `ErrorInfo`.
///    The associated `Origin` can provide context.
/// - `onCreateWithSequence`: Indicates a collision that occurred when creating an `ErrorInfo` from a sequence.
///    The associated `Origin` can provide context.
/// - `onSequenceConsumption`: Indicates a collision that occurred during the consumption of a sequence by `ErrorInfo`.
///    The associated `Origin` can provide context.
///
/// ## Methods:
/// - `defaultStringInterpolation()`: Returns a string representation of the collision source, including any relevant context.
public struct WriteProvenance: Sendable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
  // Stored backing enum
  private let backing: Backing
  
  private enum Backing: Sendable, Equatable {
    case onSubscript(origin: Origin?)
    case onAppend(origin: Origin?)
    
    case onMerge(origin: Origin)
    
    case onAddPrefix(prefix: String)
    case onAddSuffix(suffix: String)
    case onKeysMapping(original: String, mapped: String)
    
    case onCreateWithDictionaryLiteral
    case onDictionaryLiteralConsumption(origin: Origin)
    case onDictionaryConsumption(origin: Origin)
    
    case onCreateWithSequence(origin: Origin)
    case onSequenceConsumption(origin: Origin)
  }
  
  // MARK: - Public Static Initializers

  /// Creates a `WriteProvenance` for a key collision triggered by subscript access.
  internal static func onSubscript(origin: Origin?) -> Self {
    Self(backing: .onSubscript(origin: origin))
  }
      
  /// Creates a `WriteProvenance` for a key collision triggered by appending.
  internal static func onAppend(origin: Origin?) -> Self {
    Self(backing: .onAppend(origin: origin))
  }

  /// Creates a `WriteProvenance` for a key collision triggered by merging.
  internal static func onMerge(origin: Origin) -> Self {
    Self(backing: .onMerge(origin: origin))
  }

  /// Creates a `WriteProvenance` for a key collision triggered by adding a prefix.
  internal static func onAddPrefix(prefix: String) -> Self {
    Self(backing: .onAddPrefix(prefix: prefix))
  }

  /// Creates a `WriteProvenance` for a key collision triggered by adding a suffix.
  internal static func onAddSuffix(suffix: String) -> Self {
    Self(backing: .onAddSuffix(suffix: suffix))
  }

  /// Creates a `WriteProvenance` for a key collision triggered by a keys mapping operation.
  internal static func onKeysMapping(original: String, mapped: String) -> Self {
    Self(backing: .onKeysMapping(original: original, mapped: mapped))
  }

  /// Creates a `WriteProvenance` for a key collision triggered by a dictionary literal creation.
  internal static var onCreateWithDictionaryLiteral: Self {
    Self(backing: .onCreateWithDictionaryLiteral)
  }
  
  internal static func onDictionaryLiteralConsumption(origin: Origin) -> Self {
    Self(backing: .onDictionaryLiteralConsumption(origin: origin))
  }
  
  /// Creates a `WriteProvenance` for a key collision triggered by dictionary consumption.
  internal static func onDictionaryConsumption(origin: Origin) -> Self {
    Self(backing: .onDictionaryConsumption(origin: origin))
  }

  /// Creates a `WriteProvenance` for a key collision triggered by a sequence creation.
  internal static func onCreateWithSequence(origin: Origin) -> Self {
    Self(backing: .onCreateWithSequence(origin: origin))
  }

  /// Creates a `WriteProvenance` for a key collision triggered by sequence consumption.
  internal static func onSequenceConsumption(origin: Origin) -> Self {
    Self(backing: .onSequenceConsumption(origin: origin))
  }
  
  // MARK: - Public Methods
  
  public func defaultStringInterpolation() -> String {
    switch backing {
    case .onSubscript(let origin):
      let name = "onSubscript"
      return origin.map { $0._defaultStringInterpolation(collisionName: name) } ?? name
      
    case .onAppend(let origin):
      let name = "onAppend"
      return origin.map { $0._defaultStringInterpolation(collisionName: name) } ?? name
      
    case let .onMerge(origin):
      return origin._defaultStringInterpolation(collisionName: "onMerge")
      
    case let .onAddPrefix(prefix):
      return "onAddPrefix(`\(prefix)`)"
      
    case let .onAddSuffix(suffix):
      return "onAddSuffix(`\(suffix)`)"
      
    case let .onKeysMapping(original, mapped):
      return String.concat("onKeyMapping(original: `", original, "`, mapped: `", mapped, "`)")
      
    case .onCreateWithDictionaryLiteral:
      return "onCreateWithDictionaryLiteral"
      
    case let .onDictionaryLiteralConsumption(origin):
      return origin._defaultStringInterpolation(collisionName: "onDictionaryLiteralConsumption")
    
    case let .onDictionaryConsumption(origin):
      return origin._defaultStringInterpolation(collisionName: "onDictionaryConsumption")
      
    case let .onCreateWithSequence(origin):
      return origin._defaultStringInterpolation(collisionName: "onCreateWithSequence")
      
    case let .onSequenceConsumption(origin):
      return origin._defaultStringInterpolation(collisionName: "onSequenceConsumption")
    }
  }
  
  public var description: String {
    defaultStringInterpolation()
  }
  
  public var debugDescription: String {
    defaultStringInterpolation()
  }
  
  // collision short indicator variants: `   @#@    >X<    !*!  >collision*   `
}

extension WriteProvenance {
  // FIXME: - add to documentataion that Origin can be created as String literal
  
  public enum Origin: Sendable, ExpressibleByStringLiteral, Equatable {
    public typealias StringLiteralType = String
    
    case fileLine(file: String = #fileID, line: UInt = #line)
    case custom(origin: String)
    case function(function: String = #function)
    
    public init(stringLiteral origin: String) {
      self = .custom(origin: origin)
    }
    
    public static func fileLine(file: StaticString, line: UInt) -> Self {
      .fileLine(file: String(file), line: line)
    }
    
    fileprivate func _defaultStringInterpolation(collisionName: consuming String) -> String {
      switch self {
      case let .fileLine(file, line):
        String.concat(collisionName,
                      "(",
                      StringLiteralKey.fileLine.rawValue,
                      ": ",
                      ErrorInfoFuncs.fileLineString(file: file, line: line),
                      ")")
      case let .function(function):
        String.concat(collisionName, "(", StringLiteralKey.function.rawValue, ": ", function, ")")
      case let .custom(origin):
        collisionName + "(origin: " + origin + ")"
      }
    }
  }
}

// TODO: - change doc fo writeProvenance / origin arg names
