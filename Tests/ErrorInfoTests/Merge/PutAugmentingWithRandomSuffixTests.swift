//
//  PutAugmentingWithRandomSuffixTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 19/12/2025.
//

@testable import ErrorInfo
import Foundation
import OrderedCollections
import Testing

struct PutAugmentingWithRandomSuffixTests {
  private let suffixSeparator = Merge.Constants.randomSuffixBeginningForSubcriptScalar
  private let suffixSeparatorString = String(Merge.Constants.randomSuffixBeginningForSubcriptScalar)
  private let suffixLength = 4
  
  // Key does not already exist in the dictionary
  @Test func keyDoesNotExist() {
    var randomGenerator = SystemRandomNumberGenerator()
    var dict = ["apple": 0]

    Merge.DictUtils._putAugmentingWithRandomSuffix(
      assumeModifiedKey: "banana",
      value: 1,
      suffixFirstChar: suffixSeparator,
      randomGenerator: &randomGenerator,
      to: &dict,
    )

    #expect(dict.count == 2)
    #expect(dict["apple"] == 0)
    #expect(dict["banana"] == 1)
  }

  // Key already exists, random suffix is added
  @Test func keyExists() throws {
    var randomGenerator = SystemRandomNumberGenerator()
    var dict = ["apple": 0]

    // Insert a new value with the same key, which should trigger a suffix addition
    Merge.DictUtils._putAugmentingWithRandomSuffix(
      assumeModifiedKey: "apple",
      value: 1,
      suffixFirstChar: suffixSeparator,
      randomGenerator: &randomGenerator,
      to: &dict,
    )

    // Assert that the original key is still in the dictionary
    #expect(dict.count == 2)
    #expect(dict["apple"] == 0)
      
    // Assert that the modified key with suffix is added (suffix will vary, but key will contain it)
    let keysWithSuffix = dict.keys.filter { $0.unicodeScalars.contains(suffixSeparator) }
    #expect(keysWithSuffix.count == 1)
    let keyWithSuffix = try #require(keysWithSuffix.first)
    
    #expect(dict[keyWithSuffix] == 1)
    #expect(keyWithSuffix.hasPrefix("apple"))
    #expect(keyWithSuffix.components(separatedBy: suffixSeparatorString).last?.utf8.count == suffixLength)
  }
  
  // Suffix separator is space (custom)
  @Test func spaceSuffixSeparator() throws {
    var randomGenerator = SystemRandomNumberGenerator()
    var dict = ["apple": 0]

    // Insert with an empty suffix separator, expecting a collision and random suffix
    Merge.DictUtils._putAugmentingWithRandomSuffix(
      assumeModifiedKey: "apple",
      value: 1,
      suffixFirstChar: " ",
      randomGenerator: &randomGenerator,
      to: &dict,
    )

    // Assert that the original key is still in the dictionary
    #expect(dict["apple"] == 0)
    #expect(dict.count == 2)
    
    let space = " "
    let keysWithSuffix = dict.keys.filter { $0.contains(space) }
    #expect(keysWithSuffix.count == 1)
    let keyWithSuffix = try #require(keysWithSuffix.first)
    
    #expect(dict[keyWithSuffix] == 1)
    #expect(keyWithSuffix.hasPrefix("apple"))
    #expect(keyWithSuffix.components(separatedBy: space).last?.utf8.count == suffixLength)
  }

  // Multiple collisions happen, random suffixes are generated
  @Test func multipleCollisions() throws {
    var randomGenerator = SystemRandomNumberGenerator()
    
    var dict: OrderedDictionary<String, Int> = ["apple": 0]
    
    Merge.DictUtils._putAugmentingWithRandomSuffix(
      assumeModifiedKey: "apple",
      value: 1,
      suffixFirstChar: suffixSeparator,
      randomGenerator: &randomGenerator,
      to: &dict,
    )
    
    Merge.DictUtils._putAugmentingWithRandomSuffix(
      assumeModifiedKey: "apple",
      value: 2,
      suffixFirstChar: suffixSeparator,
      randomGenerator: &randomGenerator,
      to: &dict,
    )
    
    #expect(dict.count == 3)
    #expect(dict["apple"] == 0)
    
    #expect(dict.values[1] == 1)
    #expect(dict.values[2] == 2)
    
    let keysWithSuffix = dict.keys.filter { $0.unicodeScalars.contains(suffixSeparator) }
    #expect(keysWithSuffix.count == 2)
        
    #expect(keysWithSuffix.allSatisfy {
      $0.components(separatedBy: suffixSeparatorString).last?.utf8.count == suffixLength &&
        $0.hasPrefix("apple")
    })
  }
}
