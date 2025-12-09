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
  
  case onDictionaryConsumption(origin: Origin)
  case onCreateWithDictionaryLiteral // (firstKey: String)
  
  public func defaultStringInterpolation() -> String {
    let head = "!*!"
    let tail: String
    switch self {
    case .onSubscript: tail = "onSubscript"
    case .onAppend: tail = "onAppend"
    case let .onMerge(origin): return origin.defaultStringInterpolation(sourceString: "onMerge")
    case let .onAddPrefix(prefix): tail = "onAddPrefix(\"\(prefix)\")"
    case let .onAddSuffix(suffix): tail = "onAddSuffix(\"\(suffix)\")"
    case let .onKeysMapping(original, mapped): tail = "onKeyMapping(original: \"\(original)\", mapped: \"\(mapped)\")"
    case let .onDictionaryConsumption(origin): return origin.defaultStringInterpolation(sourceString: "onDictionaryConsumption")
    case .onCreateWithDictionaryLiteral: tail = "onCreateWithDictionaryLiteral"
    }
    return head + tail
  }
}

extension CollisionSource {
  public enum Origin: Sendable, ExpressibleByStringLiteral {
    case fileLine(file: StaticString = #fileID, line: UInt = #line)
    case function(function: String = #function)
    case custom(origin: String)
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral origin: String) {
      self = .custom(origin: origin)
    }
    
    /// `  @#@    >X<    !*!  >collision*`
    fileprivate func defaultStringInterpolation(sourceString: String) -> String {
      let head = "!*!" + sourceString
      let tail: String = switch self {
      case let .fileLine(file, line): "(" + "at: " + ErrorInfoFuncs.fileLineString(file: file, line: line) + ")"
      case let .function(function): "(" + "inFunction: \(function)" + ")"
      case let .custom(origin): "(" + "origin: \(origin)" + ")"
      }
      return head + tail
    }
  }
}
