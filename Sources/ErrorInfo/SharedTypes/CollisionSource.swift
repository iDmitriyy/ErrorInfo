//
//  CollisionSource.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 03/10/2025.
//

/// Represents different sources of key collisions in the context of error information.
///
/// `CollisionSource` is used to track where and how a key collision occurs. This helps in identifying the context
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
/// - `onDictionaryConsumption`: Indicates a collision that occurred during the consumption of a dictionary by `ErrorInfo`.
///    The associated `Origin` can provide context.
/// - `onCreateWithSequence`: Indicates a collision that occurred when creating an `ErrorInfo` from a sequence.
///    The associated `Origin` can provide context.
/// - `onSequenceConsumption`: Indicates a collision that occurred during the consumption of a sequence by `ErrorInfo`.
///    The associated `Origin` can provide context.
///
/// ## Methods:
/// - `defaultStringInterpolation()`: Returns a string representation of the collision source, including any relevant context.
///
/// ## Example:
/// ```swift
/// let collision = CollisionSource.onAddPrefix(prefix: "prefix_")
/// collision.defaultStringInterpolation() // "onAddPrefix(`prefix_`)"
///
/// let origin = CollisionSource.Origin.fileLine(file: #fileID, line: #line)
/// let collision2 = CollisionSource.onMerge(origin: origin)
/// collision2.defaultStringInterpolation() // "onMerge(file_line: Main.swift:42)"
/// ```
public struct CollisionSource: Sendable {
  // Stored backing enum
  private let backing: CollisionSourceBacking
  
  private enum CollisionSourceBacking: Sendable {
    case onSubscript(origin: Origin?)
    case onAppend(origin: Origin?)
    
    case onMerge(origin: Origin)
    
    case onAddPrefix(prefix: String)
    case onAddSuffix(suffix: String)
    case onKeysMapping(original: String, mapped: String)
    
    case onCreateWithDictionaryLiteral
    case onDictionaryConsumption(origin: Origin)
    
    case onCreateWithSequence(origin: Origin)
    case onSequenceConsumption(origin: Origin)
  }
  
  // MARK: - Public Static Initializers

  /// Creates a `CollisionSource` for a key collision triggered by subscript access.
  public static func onSubscript(origin: Origin?) -> CollisionSource {
    CollisionSource(backing: .onSubscript(origin: origin))
  }
      
  /// Creates a `CollisionSource` for a key collision triggered by appending.
  public static func onAppend(origin: Origin?) -> CollisionSource {
    CollisionSource(backing: .onAppend(origin: origin))
  }

  /// Creates a `CollisionSource` for a key collision triggered by merging.
  public static func onMerge(origin: Origin) -> CollisionSource {
    CollisionSource(backing: .onMerge(origin: origin))
  }

  /// Creates a `CollisionSource` for a key collision triggered by adding a prefix.
  public static func onAddPrefix(prefix: String) -> CollisionSource {
    CollisionSource(backing: .onAddPrefix(prefix: prefix))
  }

  /// Creates a `CollisionSource` for a key collision triggered by adding a suffix.
  public static func onAddSuffix(suffix: String) -> CollisionSource {
    CollisionSource(backing: .onAddSuffix(suffix: suffix))
  }

  /// Creates a `CollisionSource` for a key collision triggered by a keys mapping operation.
  public static func onKeysMapping(original: String, mapped: String) -> CollisionSource {
    CollisionSource(backing: .onKeysMapping(original: original, mapped: mapped))
  }

  /// Creates a `CollisionSource` for a key collision triggered by a dictionary literal creation.
  public static var onCreateWithDictionaryLiteral: CollisionSource {
    CollisionSource(backing: .onCreateWithDictionaryLiteral)
  }

  /// Creates a `CollisionSource` for a key collision triggered by dictionary consumption.
  public static func onDictionaryConsumption(origin: Origin) -> CollisionSource {
    CollisionSource(backing: .onDictionaryConsumption(origin: origin))
  }

  /// Creates a `CollisionSource` for a key collision triggered by a sequence creation.
  public static func onCreateWithSequence(origin: Origin) -> CollisionSource {
    CollisionSource(backing: .onCreateWithSequence(origin: origin))
  }

  /// Creates a `CollisionSource` for a key collision triggered by sequence consumption.
  public static func onSequenceConsumption(origin: Origin) -> CollisionSource {
    CollisionSource(backing: .onSequenceConsumption(origin: origin))
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
      
    case let .onDictionaryConsumption(origin):
      return origin._defaultStringInterpolation(collisionName: "onDictionaryConsumption")
      
    case .onCreateWithDictionaryLiteral:
      return "onCreateWithDictionaryLiteral"
      
    case let .onCreateWithSequence(origin):
      return origin._defaultStringInterpolation(collisionName: "onCreateWithSequence")
      
    case let .onSequenceConsumption(origin):
      return origin._defaultStringInterpolation(collisionName: "onSequenceConsumption")
    }
  }
  
  // collision short indicator variants: `   @#@    >X<    !*!  >collision*   `
}

extension CollisionSource {
  // FIXME: - add to documentataion that Origin can be created as String literal
  
  public enum Origin: Sendable, ExpressibleByStringLiteral {
    public typealias StringLiteralType = StaticString
    
    case fileLine(file: StaticString = #fileID, line: UInt = #line)
    case function(function: String = #function)
    case custom(origin: String)
    
    public init(stringLiteral origin: StringLiteralType) {
      self = .custom(origin: String(origin))
    }
    
    internal func _defaultStringInterpolation(collisionName: consuming String) -> String {
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
