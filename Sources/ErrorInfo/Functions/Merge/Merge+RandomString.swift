//
//  RandomString.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 28/07/2025.
//

import NonEmpty

// MARK: - Random Suffix

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
  /// // suffix might be something like "a3L9"
  /// ```
  @_spi(PerformanceTesting) @_spi(Testing)
  @inlinable @inline(__always) // 1.7x speedup
  @Sendable public static func randomSuffix(generator: inout some RandomNumberGenerator) -> NonEmptyString {
    // ~14,7 million of combinations for count = 4, duplicated string typically appear after several thousands of calls
    // for count == 3 duplicate typically appears in range 200-1000 of calls
    _randomBase62String(count: 4, randomGenerator: &generator)
  }
    
  @inlinable @inline(__always)
  internal static func _randomBase62String(count: UInt8,
                                           randomGenerator: inout some RandomNumberGenerator) -> NonEmptyString {
    let count = Int(count == 0 ? 1 : count)
        
    var result = count < 16 ? String() : String(minimumCapacity: count)
    for _ in 0..<count {
      let randomValue = Merge.Constants.alphaNumericAsciiCodes.randomElement(using: &randomGenerator)!
      result.unicodeScalars.append(UnicodeScalar(randomValue))
    }
    return NonEmptyString(base: result)!
  }
}

extension Merge.Constants {
  /// Includes ASCII values: `97 to 122 (a-z)`, `65 to 90 (A-Z)`, and `48 to 57 (0-9)`.
  @usableFromInline
  internal static let alphaNumericAsciiCodes: ContiguousArray<UInt8> = mutate(value: ContiguousArray<UInt8>()) {
    $0.reserveCapacity(62)
    $0.append(contentsOf: 97...122) // lowerCaseAsciiRange
    $0.append(contentsOf: 65...90) // upperCaseAsciiRange
    $0.append(contentsOf: 48...57) // numericAsciiRange
  }
}
