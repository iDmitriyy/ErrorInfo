//
//  RandomSuffixTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

@testable import ErrorInfo
import Foundation
import NonEmpty
import Testing

struct RandomSuffixTests {
  @Test func format() throws {
    var generator = SystemRandomNumberGenerator()
    let randomSuffixes = (1...100).map { _ in ErrorInfoFuncs.randomSuffix(generator: &generator) }
    
    for randomSuffix in randomSuffixes {
      let randomSuffix = randomSuffix.rawValue
      randomSuffix.count == 3
      randomSuffix.unicodeScalars.count == 3 // supposed to contain ASCII symbols
      
      let first = randomSuffix.first
      let second = randomSuffix[randomSuffix.index(after: randomSuffix.startIndex)]
      let third = randomSuffix.last
      }
    
    var uniqieSuffixes: Set<String> = []
    var counter: Int = 0
    var nexSuffix = ErrorInfoFuncs.randomSuffix(generator: &generator).rawValue
    while !uniqieSuffixes.contains(nexSuffix) {
      uniqieSuffixes.insert(nexSuffix)
      nexSuffix = ErrorInfoFuncs.randomSuffix(generator: &generator).rawValue
      counter += 1
    }
    print("_______ next siffux duplicated at \(counter)")
  }
}
