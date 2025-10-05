//
//  NonEmptyOrderedIndexSetLayoutTests.swift
//  ErrorInfo
//
//  Created by tmp on 05/10/2025.
//

@testable import ErrorInfo
import Testing
import SwiftCollectionsNonEmpty

struct NonEmptyOrderedIndexSetLayoutTests {
  @Test func `size is valid`() {
    let memoryLayout = MemoryLayout<NonEmptyOrderedIndexSet>.self
    let integerLayout = MemoryLayout<Int>.self
    let nonEmptyOrderedSetLayout = MemoryLayout<NonEmptyOrderedSet<Int>>.self
    
    // NonEmptyOrderedIndexSet is expected to consume not more than twice amount of memory in comparison with
    // storing single Int index
    #expect(memoryLayout.size <= integerLayout.size * 2)
    #expect(memoryLayout.stride <= integerLayout.stride * 2)
    
    // NonEmptyOrderedIndexSet is expected to consume not more memory than heap allocated NonEmptyOrderedSet
    #expect(memoryLayout.size <= nonEmptyOrderedSetLayout.size)
    #expect(memoryLayout.stride <= nonEmptyOrderedSetLayout.stride)
  }
}
