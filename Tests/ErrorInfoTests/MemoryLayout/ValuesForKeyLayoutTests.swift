//
//  ValuesForKeyLayoutTests.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

@testable import ErrorInfo
import Testing

struct ValuesForKeyLayoutTests {
  @Test func `size limits`() {
    let memoryLayout = MemoryLayout<ValuesForKey<any ErrorInfoValueType>>.self
    let errorInfoValueTypeLayout = MemoryLayout<any ErrorInfoValueType>.self
    let arrayLayout = MemoryLayout<Array<any ErrorInfoValueType>>.self
    
    // NonEmptyOrderedIndexSet is expected to consume not more than twice amount of memory in comparison with
    // storing single Int index
    let values = VariadicTuple(memoryLayout.size,
                               memoryLayout.stride,
                               errorInfoValueTypeLayout.size,
                               errorInfoValueTypeLayout.stride,
                               arrayLayout.size,
                               arrayLayout.stride)
    
    print("")
    
    #expect(memoryLayout.stride == errorInfoValueTypeLayout.stride + arrayLayout.stride)
  }
}
