//
//  CollisionSource.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 03/10/2025.
//

// TODO: make as struct with static functions

public enum CollisionSource: Sendable {
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
  
  // collision short indicator variants: `   @#@    >X<    !*!  >collision*   `
  
  public func defaultStringInterpolation() -> String {
    switch self {
    case .onSubscript(let origin):
      let name = "onSubscript"
      return origin.map { $0._defaultStringInterpolation(collisionName: name) } ?? name
      
    case .onAppend(let origin):
      let name = "onAppend"
      return origin.map { $0._defaultStringInterpolation(collisionName: name) } ?? name
      
    case let .onMerge(origin):
      return origin._defaultStringInterpolation(collisionName: "onMerge")
      
    case let .onAddPrefix(prefix):
      // Improvement: may be `String.concat(...)` is faster than interpolation
      return "onAddPrefix(`\(prefix)`)"
      
    case let .onAddSuffix(suffix): 
      return "onAddSuffix(`\(suffix)`)"
      
    case let .onKeysMapping(original, mapped):
      return String.concat("onKeyMapping(original: `", original, "`, mapped: `", mapped, "`)")
      
    case let .onDictionaryConsumption(origin):
      return origin._defaultStringInterpolation(collisionName: "onDictionaryConsumption")
      
    case .onCreateWithDictionaryLiteral: 
      return "onCreateWithDictionaryLiteral"
    }
  }
}

extension CollisionSource {
  // ⚠️ @iDmitriyy
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
        String.concat(collisionName, "(origin: ", origin, ")")
      }
    }
  }
}
