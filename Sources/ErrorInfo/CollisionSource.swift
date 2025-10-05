//
//  CollisionSource.swift
//  ErrorInfo
//
//  Created by tmp on 03/10/2025.
//

public enum CollisionSource: Sendable {
  case onSubscript
  case onMerge(origin: MergeOrigin)
  case onAddPrefix(prefix: String)
  case onAddSuffix(suffix: String)
  case onCreateWithDictionaryLiteral
  // case onKeysMapping(original: String, mapped: String)
  
  public func defaultStringInterpolation() -> String {
    let head = "!*!"
    let tail: String
    switch self {
    case let .onMerge(origin): return origin.defaultStringInterpolation()
    case .onSubscript: tail = "onSubscript"
    case let .onAddPrefix(prefix): tail = "onAddPrefix(\"\(prefix)\")"
    case let .onAddSuffix(suffix): tail = "onAddSuffix(\"\(suffix)\")"
    case .onCreateWithDictionaryLiteral: tail = "onCreateWithDictionaryLiteral"
    }
    return head + tail
  }
}

extension CollisionSource {
  public enum MergeOrigin: Sendable, ExpressibleByStringLiteral {
    case fileLine(file: StaticString = #fileID, line: UInt = #line)
    case function(function: String = #function)
    case custom(origin: String)
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral origin: String) {
      self = .custom(origin: origin)
    }
    
    /// `  @#@    >X<    !*!  >collision*`
    public func defaultStringInterpolation() -> String {
      let head = "!*!" + "onMerge"
      let tail: String = switch self {
      case let .fileLine(file, line): "(" + "at: \(file):\(line)" + ")"
      case let .function(function): "(" + "inFunction: \(function)" + ")"
      case let .custom(origin): "(" + "origin: \(origin)" + ")"
      }
      return head + tail
    }
  }
}
