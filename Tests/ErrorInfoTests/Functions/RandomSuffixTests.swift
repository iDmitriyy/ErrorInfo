//
//  RandomSuffixTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

@testable @_spi(Testing) import ErrorInfo
import Foundation
import NonEmpty
import Testing

struct RandomSuffixTests {
  private let base62 = mutate(value: Set<UInt8>()) {
    $0.reserveCapacity(62)
    $0.formUnion(97...122) // lowerCaseAsciiRange
    $0.formUnion(65...90) // upperCaseAsciiRange
    $0.formUnion(48...57) // numericAsciiRange
  }
  
  @Test func format() throws {
    var generator = SystemRandomNumberGenerator() // TestableWithIncrementNumberGenerator(value: 0, step: 1)
    let expectedMaxDuplicates = 3
    
    let numberOfSuffixes = 1000
    let randomSuffixes = mutate(value: ContiguousArray<String>()) {
      $0.reserveCapacity(numberOfSuffixes)
      for _ in 1...numberOfSuffixes {
        $0.append(Merge.Utils.randomSuffix(generator: &generator).base)
      }
    }
    
    // Test:
    // - randomSuffix generates a exactly 4-ascii symbols string
    // - generates only base62 ASCII characters (a-z, A-Z, 0-9)
    let expectedAsciiLength = 4
    let isFromatValid = randomSuffixes.allSatisfy { randomSuffix in
      randomSuffix.utf8.count == expectedAsciiLength && randomSuffix.utf8.allSatisfy { code in base62.contains(code) }
    }
    
    #expect(isFromatValid)
              
    var uniqieSuffixes = Set<String>(minimumCapacity: numberOfSuffixes)
    var duplicatedSufixes = Set<String>(minimumCapacity: 10)
    for suffix in randomSuffixes {
      if !uniqieSuffixes.insert(suffix).inserted {
        duplicatedSufixes.insert(suffix)
      }
    }
    
    #expect(duplicatedSufixes.count <= expectedMaxDuplicates)
    
    // The test was executed 1_000_000 times, generating a total of 1 billion random suffixes.
    // Below are the statistics for the number of duplicate suffixes found among 1000 suffixes per test run:
    // - "Count of duplicates" refers to the number of duplicate suffixes found within a batch of 1000 suffixes.
    // - "Frequency" indicates how many times that specific count of duplicates occurred.
    // - "Percentage" shows the frequency of each count of duplicates as a percentage of 1_000_000 total tests.

    // Count of Duplicates | Frequency | Percentage of 1,000,000 Generations
    //          1          :   32,988  :    3.3%
    //          2          :    567    :    0.057%
    //          3          :     9     :    0.0009% (1 time per 100_000 runs)
    
    // So, if this test is run 10 times each day, the situation where 3 duplicates is found happens 1 time per 30 years
  }
}
