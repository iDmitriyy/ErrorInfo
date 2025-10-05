//
//  NonEmptyOrderedIndexSetLayoutTests.swift
//  ErrorInfo
//
//  Created by tmp on 05/10/2025.
//

@testable import ErrorInfo
import Testing

struct NonEmptyOrderedIndexSetLayoutTests {
  @Test func `size is valid`() {
    let memoryLayout = MemoryLayout<NonEmptyOrderedIndexSet>.self
    let integerMemoryLayout = MemoryLayout<Int>.self
    
    // NonEmptyOrderedIndexSet is expected to consume not more then twice amount of memory in comparison with storing Int
    #expect(memoryLayout.size <= integerMemoryLayout.size * 2)
    #expect(memoryLayout.stride <= integerMemoryLayout.stride * 2)
  }
}
