//
//  KeysTransformTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16.04.2025.
//

@testable import ErrorInfo
import Foundation
import Testing

struct KeysTransformTests {
  private static let expectedAlwaysStayUnmodified: [String] = [
    "",
    " ",
    "  ",
    "...",
  ]
    
  private let keys: [String] = [
    "snake_case_key",
    "camelCaseKey",
    "kebab-case-key",
    "PascalCaseKey",
    // + "requestURL" (sublime add extra _ at the end)
    "this-is-a-test-Key",
    "This-Is-Mixed-CASE",
    "underscore_and-hyphen",
    "testäöüßÄÖÜ",
    "ßteßt",
    "____many___underscores__",
    "----many---hyphens--",
    "_________", // only underscores
    "---------", // only hyphens
    "RepeatedUPPERCASE",
    "string.with.dots",
    "string.WiTh.dOtS2",
    "string&WIth*|",
  ] + expectedAlwaysStayUnmodified
  // TODO: Add not only english capitalized
  
  // MARK: - Tests
  
  @Test func fromAnyStyleToCamelCased() throws {
    let camelCased = keys.map(ErrorInfoFuncs.fromAnyStyleToCamelCased(string:))
    
    let expected = [
      "snakeCaseKey",
      "camelCaseKey",
      "kebabCaseKey",
      "pascalCaseKey",
      "thisIsATestKey",
      "thisIsMixedCASE",
      "underscoreAndHyphen",
      "testäöüßÄÖÜ",
      "ßteßt",
      "manyUnderscores",
      "manyHyphens",
      "_________", // only underscores
      "---------", // only hyphens
      "repeatedUPPERCASE",
      "string.with.dots",
      "string.WiTh.dOtS2",
      "string&WIth*|",
    ] + KeysTransformTests.expectedAlwaysStayUnmodified
    
    let diff = Set(camelCased).subtracting(expected)
    #expect(diff.isEmpty)
  }
  
  @Test func fromAnyStyleToPascalCased() throws {
    let pascalCased = keys.map(ErrorInfoFuncs.fromAnyStyleToPascalCased(string:))
    
    let expected = [
      "SnakeCaseKey",
      "CamelCaseKey",
      "KebabCaseKey",
      "PascalCaseKey",
      "ThisIsATestKey",
      "ThisIsMixedCASE",
      "UnderscoreAndHyphen",
      "TestäöüßÄÖÜ",
      "SSteßt",
      "ManyUnderscores",
      "ManyHyphens",
      "_________", // only underscores
      "---------", // only hyphens
      "RepeatedUPPERCASE",
      "String.with.dots",
      "String.WiTh.dOtS2",
      "String&WIth*|",
    ] + KeysTransformTests.expectedAlwaysStayUnmodified
    
    let diff = Set(pascalCased).subtracting(expected)
    #expect(diff.isEmpty)
  }
  
  @Test func fromAnyStyleToSnakeCased() throws {
    let snakeCased = keys.map(ErrorInfoFuncs.fromAnyStyleToSnakeCased(string:))
    
    let expected = [
      "snake_case_key",
      "camel_case_key",
      "kebab_case_key",
      "pascal_case_key",
      "this_is_a_test_key",
      "this_is_mixed_case",
      "underscore_and_hyphen",
      "testäöüß_äöü",
      "ßteßt",
      "____many___underscores__",
      "____many___hyphens__",
      "_________", // only underscores
      "_________", // only hyphens
      "repeated_uppercase",
      "string.with.dots",
      "string._wi_th.d_ot_s2",
      "string&_with*|",
    ] + KeysTransformTests.expectedAlwaysStayUnmodified
    
    let diff = Set(snakeCased).subtracting(expected)
    #expect(diff.isEmpty)
  }
  
  @Test func fromAnyStyleToKebabCased() throws {
    let snakeCased = keys.map(ErrorInfoFuncs.fromAnyStyleToKebabCased(string:))
    
    let expected = [
      "snake-case-key",
      "camel-case-key",
      "kebab-case-key",
      "pascal-case-key",
      "this-is-a-test-key",
      "this-is-mixed-case",
      "underscore-and-hyphen",
      "testäöüß-äöü",
      "ßteßt",
      "----many---underscores--",
      "----many---hyphens--",
      "---------", // only underscores
      "---------", // only hyphens
      "repeated-uppercase",
      "string.with.dots",
      "string.-wi-th.d-ot-s2",
      "string&-with*|",
    ] + KeysTransformTests.expectedAlwaysStayUnmodified
    
    let diff = Set(snakeCased).subtracting(expected)
    #expect(diff.isEmpty)
  }
}
