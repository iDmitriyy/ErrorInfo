//
//  ValuesForKeyLayoutTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

@testable import ErrorInfo
import Testing

struct ValuesForKeyLayoutTests {
  @Test func `size limits`() {
    let memoryLayout = MemoryLayout<ValuesForKey<ErrorInfo.ValueExistential>>.self
    let errorInfoValueTypeLayout = MemoryLayout<ErrorInfo.ValueExistential>.self
    let arrayLayout = MemoryLayout<Array<ErrorInfo.ValueExistential>>.self
    
    // NonEmptyOrderedIndexSet is expected to consume not more than twice amount of memory in comparison with
    // storing single Int index
    let values = VariadicTuple(memoryLayout.size,
                               memoryLayout.stride,
                               errorInfoValueTypeLayout.size,
                               errorInfoValueTypeLayout.stride,
                               arrayLayout.size,
                               arrayLayout.stride)
    
    print("")
    
    let recordLayout = MemoryLayout<ErrorInfo.BackingStorage.Record>.self
    print(VariadicTuple(recordLayout.size, recordLayout.stride))
    
    #expect(memoryLayout.stride == errorInfoValueTypeLayout.stride + arrayLayout.stride)
  }
}
