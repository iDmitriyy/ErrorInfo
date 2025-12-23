//
//  CollisionSourceLayoutTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/12/2025.
//

@testable import ErrorInfo
import Testing

struct CollisionSourceLayoutTests {
  @Test func `size limits`() {
    let memoryLayout = MemoryLayout<WriteProvenance>.self
    
    let tuple = VariadicTuple(memoryLayout.size, memoryLayout.stride)
    
    print(tuple)
  }
}
