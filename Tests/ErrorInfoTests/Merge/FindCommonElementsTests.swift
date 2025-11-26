//
//  FindCommonElementsTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 26/11/2025.
//

import Collections
@testable import ErrorInfo
import Testing

struct FindCommonElementsTests {
  @Test func basic() throws {
    let set1: Set<Int> = [1, 2, 3, 4, 5]
    let set2: Set<Int> = [3, 4, 5, 6]
    let set3: Set<Int> = [4, 5, 7, 8]
   
    #expect(findCommonElements(across: [set1, set2, set3]) == Set([3, 4, 5]))
  }
}
