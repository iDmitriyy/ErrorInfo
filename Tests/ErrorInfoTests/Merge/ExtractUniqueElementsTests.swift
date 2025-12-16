//
//  ExtractUniqueElementsTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 26/11/2025.
//

@testable import ErrorInfo
import NonEmpty
import Testing

struct ExtractUniqueElementsTests {
  @Test func basic() throws {
    let input = NonEmptyArray(0, 1, 1, 1, 1, 2, 3, 2, 3, 2, 1, 4)
    let expected = NonEmptyArray(0, 1, 2, 3, 4)
    
    // #expect(extractUniqueElements(from: input, equalFuncImp: ==) == expected)
  }
}
