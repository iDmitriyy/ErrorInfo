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
  /// Converts a KeyPath into a string representation.
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
