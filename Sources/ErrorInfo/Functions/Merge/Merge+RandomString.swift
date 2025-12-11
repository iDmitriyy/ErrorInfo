//
//  RandomString.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

import NonEmpty

// MARK: Random Suffix

extension Merge.Utils {
  /// Generates a random suffix string consisting of 4 printable ASCII characters (letters or digits).
  ///
  /// - Parameters:
  ///   - generator: A mutable random number generator used to generate random elements.
  /// - Returns: A non-empty string of random printable ASCII characters.
  ///
  /// **Example:**
  /// ```swift
  /// var generator = SystemRandomNumberGenerator()
  /// let suffix = ErrorInfoFuncs.randomSuffix(generator: &generator)
  /// // suffix might be something like "a3@9"
  /// ```
  @_spi(PerfomanceTesting)
  @inlinable @inline(__always) // 1.7x speedup
  @Sendable public static func randomSuffix(generator: inout some RandomNumberGenerator) -> NonEmptyString {
    // ~11,4 million of combinations
    // duplicated string typically created after several thousands for count = 4
    // for count == 3 duplicate typically appears in range 200-1000
    _randomPrintableAsciiCharsString(count: 4, randomGenerator: &generator)
  }
    
  @inlinable @inline(__always)
  internal static func _randomPrintableAsciiCharsString(count: UInt8,
                                                        randomGenerator: inout some RandomNumberGenerator) -> NonEmptyString {
    let count = Int(count == 0 ? 1 : count)
        
    var result = String(minimumCapacity: count)
    result.unicodeScalars.append(UnicodeScalar(Merge.Constants.alphaNumericAsciiSet.randomElement()!))
    
    for index in 1..<count {
      let randomAsciiNumber: UInt8 = if index == 0 || index == count - 1 {
        Merge.Constants.alphaNumericAsciiSet.randomElement(using: &randomGenerator)!
      } else {
        // in the middle of the string extended charset is used
        Merge.Constants.allPrintableExcludingReservedAsciiSet.randomElement(using: &randomGenerator)!
      }
      result.unicodeScalars.append(UnicodeScalar(randomAsciiNumber))
    }
    
    return NonEmptyString(rawValue: result)!
  }
}

extension Merge.Constants {
  /// Includes ASCII values: `97 to 122 (a-z)`, `65 to 90 (A-Z)`, and `48 to 57 (0-9)`.
  @usableFromInline
  internal static let alphaNumericAsciiSet: Set<UInt8> = mutate(value: Set<UInt8>()) {
    $0.formUnion(97...122) // lowerCaseAsciiRange
    $0.formUnion(65...90) // upperCaseAsciiRange
    $0.formUnion(48...57) // numericAsciiRange
  }

  /// ASCII values for all printable characters `(33 to 126)`, excluding certain reserved symbols, typically treated as special symbols or used in folder paths.
  @usableFromInline
  internal static let allPrintableExcludingReservedAsciiSet: Set<UInt8> = mutate(value: Set<UInt8>()) {
    $0.formUnion(33...126) // all printable characters except space
    
    // remove also some others symbols, that are reserved by ErrorInfo functions or often used in error-info keys.
    // e.g. folder path path can be used as a key.
    $0.remove(randomSuffixBeginningForMergeAsciiCode)
    $0.remove(randomSuffixBeginningForMergeAsciiCode)
    $0.remove(45) // hyphen -
    $0.remove(47) // forward slash /
    $0.remove(92) // backslash \
    $0.remove(95) // underscore _
    $0.remove(22) // double quote "
    $0.remove(27) // single quote '
    $0.remove(60) // backtick `
  }
}
