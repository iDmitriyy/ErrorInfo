//
//  ErrorInfoKeysTransform.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

// MARK: - Key Styles Transform

extension ErrorInfoFuncs {
  /// Converts a string to camel case, where the first letter is lowercase and each subsequent word starts with an uppercase letter.
  ///
  /// - Parameter string: The string to convert, potentially containing separators like underscores or hyphens.
  /// - Returns: A camel-cased string.
  ///
  /// # Examples:
  /// ```swift
  /// ErrorInfoFuncs.fromAnyStyleToCamelCased(string: "camelCaseExample")
  /// // "camelCaseExample"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToCamelCased(string: "snake_case_example")
  /// // "snakeCaseExample"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToCamelCased(string: "kebab-case-example")
  /// // "kebabCaseExample"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToCamelCased(string: "____many___underscores__")
  /// // "manyUnderscores"
  /// ```
  public static func fromAnyStyleToCamelCased(string: String) -> String {
    _toPascalOrCamelImp(string: string, firstCharTransform: { $0.lowercased() })
  }
  
  /// Converts a string to Pascal case, where the first letter is uppercase and each subsequent word starts with an uppercase letter.
  ///
  /// - Parameter string: The string to convert, potentially containing separators like underscores or hyphens.
  /// - Returns: A Pascal-cased string.
  ///
  /// # Examples:
  /// ```swift
  /// ErrorInfoFuncs.fromAnyStyleToPascalCased(string: "camelCaseExample")
  /// // "CamelCaseExample"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToPascalCased(string: "snake_case_example")
  /// // "SnakeCaseExample"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToPascalCased(string: "kebab-case-example")
  /// // "KebabCaseExample"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToPascalCased(string: "____many___underscores__")
  /// // "ManyUnderscores"
  /// ```
  public static func fromAnyStyleToPascalCased(string: String) -> String {
    _toPascalOrCamelImp(string: string, firstCharTransform: { $0.uppercased() })
  }
  
  /// Converts a string to snake case, where words are separated by underscores and all characters are lowercase.
  ///
  /// - Parameter string: The string to convert, potentially containing separators like underscores or hyphens.
  /// - Returns: A snake-cased string.
  ///
  /// # Examples:
  /// ```swift
  /// ErrorInfoFuncs.fromAnyStyleToSnakeCased(string: "camelCaseExample")
  /// // "camel_case_example"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToSnakeCased(string: "snake_case_example")
  /// // "snake_case_example"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToSnakeCased(string: "kebab-case-example")
  /// // "kebab_case_example"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToSnakeCased(string: "----many---hyphens--")
  /// // "____many___hyphens__"
  /// ```
  public static func fromAnyStyleToSnakeCased(string: String) -> String {
    _toSnakeOrKebabImp(string: string, separator: "_")
  }
  
  /// Converts a string to kebab case, where words are separated by hyphens and all characters are lowercase.
  ///
  /// - Parameter string: The string to convert, potentially containing separators like underscores or hyphens.
  /// - Returns: A kebab-cased string.
  ///
  /// # Examples:
  /// ```swift
  /// ErrorInfoFuncs.fromAnyStyleToKebabCased(string: "CamelCaseExample")
  /// // "camel-case-example"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToKebabCased(string: "snake_case_example")
  /// // "snake-case-example"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToKebabCased(string: "kebab-case-example")
  /// // "kebab-case-example"
  ///
  /// ErrorInfoFuncs.fromAnyStyleToKebabCased(string: "____many___underscores__")
  /// // "----many---underscores--"
  /// ```
  public static func fromAnyStyleToKebabCased(string: String) -> String {
    _toSnakeOrKebabImp(string: string, separator: "-")
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Generic Imps

extension ErrorInfoFuncs {
  private static func _toPascalOrCamelImp(string: String, firstCharTransform: (Character) -> String) -> String {
    var result = "" // result.reserveCapacity - has slightly negative impact on perfomance
    
    var hasSeenNormalChar = false
    var previousWasSeprator = false
    for character in string {
      if character == "_" || character == "-" {
        previousWasSeprator = true
      } else { // normal (non-separator) character:
        if hasSeenNormalChar {
          if previousWasSeprator { // If after separator then uppercased
            result.append(character.uppercased())
          } else {
            result.append(character)
          }
        } else { // first normal char
          result.append(firstCharTransform(character))
          hasSeenNormalChar = true
        }
        previousWasSeprator = false
      } // end if
    } // end for
    return hasSeenNormalChar ? result : string
  }
  
  private static func _toSnakeOrKebabImp(string: String, separator: Character) -> String {
    enum PreviousCharKind {
      case uppercase
      case lowercase
      case separator
    }
    
    var result = "" // result.reserveCapacity - has slightly negative impact on perfomance
    
    var previousKind: PreviousCharKind?
    for character in string {
      if character == "_" || character == "-" {
        result.append(separator)
        previousKind = .separator
      } else { // normal (non-separator) character:
        if character.isUppercase {
          if let previousKind, !(previousKind == .separator), !(previousKind == .uppercase) {
            // append separator only before first Capitalised char in each word execpt first word, only if previous char
            // was not a separator.
            result.append(separator)
          }
          result.append(character.lowercased())
          previousKind = .uppercase
        } else {
          result.append(character)
          previousKind = .lowercase
        }
      } // end if
    } // end for
    return result
  }
}
