//
//  CollisionSpecifier.swift
//  ErrorInfo
//
//  Created by tmp on 03/10/2025.
//

public enum CollisionSourceSpecifier: Sendable {
  case onSubscript
  case onMerge(specifier: OnMerge)
  case onAddPrefix(prefix: String)
  case onAddSuffix(suffix: String)
  // case onKeysMapping(original: String, mapped: String)
  
  public func defaultStringInterpolation() -> String {
    let head = "!*!"
    let tail: String
    switch self {
    case let .onMerge(specifier): return specifier.defaultStringInterpolation()
    case .onSubscript: tail = "onSubscript"
    case let .onAddPrefix(prefix): tail = "onAddPrefix(\"\(prefix)\")"
    case let .onAddSuffix(suffix): tail = "onAddSuffix(\"\(suffix)\")"
    }
    return head + tail
  }
}

extension CollisionSourceSpecifier {
  public enum OnMerge: Sendable, ExpressibleByStringLiteral {
    case fileLine(file: StaticString = #fileID, line: UInt = #line)
    case function(function: String = #function)
    case custom(specifier: String)
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: String) {
      self = .custom(specifier: value)
    }
    
    /// `  @#@    >X<    !*!  >collision*`
    public func defaultStringInterpolation() -> String {
      let head = "!*!" + "onMerge"
      let tail: String = switch self {
      case let .fileLine(file, line): "(" + "at: \(file):\(line)" + ")"
      case let .function(function): "(" + "inFunction: \(function)" + ")"
      case let .custom(specifier): "(" + "specifier: \(specifier)" + ")"
      }
      return head + tail
    }
  }
}
