//
//  ErrorInfoKeyFromKeyPathTests.swift
//  ErrorInfo
//
//  Created by tmp on 26/10/2025.
//

@testable import ErrorInfo
import Testing

struct ErrorInfoKeyFromKeyPathTests {
  @Test func keyPathString() throws {    
    let count = ErrorInfoFuncs.asErrorInfoKeyString(keyPath: \String.count, withTypePrefix: false)
    let countWithTypePrefix = ErrorInfoFuncs.asErrorInfoKeyString(keyPath: \String.count, withTypePrefix: true)
    
    #expect(count == "count")
    #expect(countWithTypePrefix == "String.count")
    
    print(count, countWithTypePrefix)
  }
}
