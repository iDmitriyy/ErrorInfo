//
//  ErrorInfoFunctions.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

// MARK: - Merge ErrorInfo

/// Namespacing
public enum ErrorInfoFuncs {}

extension ErrorInfoFuncs {
  /// Namespacing
  public enum DictUtils {}
}

extension ErrorInfoFuncs {
  /// Namespacing for private imps that should be inlined
  @usableFromInline internal enum __PrivateImps {}
}

extension ErrorInfoFuncs {
  /// Converts a KeyPath into a string representation.
  ///
  /// If `withTypePrefix` is `true`, the result includes type and property name (e.g. `"Foo.count"`).
  ///
  /// If `false`, it returns just the property name, excluding the type (e.g. `"count"`).
  @usableFromInline internal static func asErrorInfoKeyString<R, V>(keyPath: KeyPath<R, V>, withTypePrefix: Bool) -> String {
    let keyPathString = String(reflecting: keyPath) // e.g. "\Foo.count"
    if withTypePrefix {
      return String(keyPathString.dropFirst())
    } else {
      guard let dotIndex = keyPathString.firstIndex(of: ".") else { return keyPathString }
      let nextAfterDotIndex = keyPathString.index(after: dotIndex)
            
      return String(keyPathString[nextAfterDotIndex...])
    }
    /// https://github.com/apple/swift-evolution/blob/main/proposals/0369-add-customdebugdescription-conformance-to-anykeypath.md
  } // inlining has no effect on performance
  
  /// Combines the file name and line number.
  /// - Returns: Example: `"File.swift:42"`
  public static func fileLineString(file: StaticString, line: UInt) -> String { // inlining has no effect on performance
    fileLineString(file: String(file), line: line)
  }
  
  public static func fileLineString(file: String, line: UInt) -> String { // inlining has no effect on performance
    file + ":\(line)"
  }
  
  internal static func nilString(typeOfWrapped: any Any.Type) -> String {
    "nil (\(typeOfWrapped))"
  }
}
