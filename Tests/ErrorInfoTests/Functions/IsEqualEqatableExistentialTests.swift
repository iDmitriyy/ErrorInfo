//
//  IsEqualEqatableExistentialTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 26/11/2025.
//

@testable import ErrorInfo
import Testing

struct IsEqualEqatableExistentialTests {
  @Test func basic() throws {
    // Equal values
    #expect(ErrorInfoFuncs.isEqualEquatableExistential(a: Int(1), b: Int(1)))
    
    #expect(ErrorInfoFuncs.isEqualEquatableExistential(a: Int(1),
                                                      b: Int(1) as any BinaryInteger & Sendable))
    #expect(ErrorInfoFuncs.isEqualEquatableExistential(a: Int(1) as any BinaryInteger & Sendable,
                                                      b: Int(1)))
    
    #expect(ErrorInfoFuncs.isEqualEquatableExistential(a: Int(1) as any BinaryInteger & Sendable,
                                                      b: Int(1) as any BinaryInteger & Sendable))
    
    // Not Equal types
    
    #expect(!ErrorInfoFuncs.isEqualEquatableExistential(a: Int(1),
                                                       b: UInt(1)))
    #expect(!ErrorInfoFuncs.isEqualEquatableExistential(a: UInt(1),
                                                       b: Int(1)))
    
    #expect(!ErrorInfoFuncs.isEqualEquatableExistential(a: Int(1) as any BinaryInteger & Sendable,
                                                       b: UInt(1)))
    #expect(!ErrorInfoFuncs.isEqualEquatableExistential(a: UInt(1) as any BinaryInteger & Sendable,
                                                       b: Int(1)))
    
    #expect(!ErrorInfoFuncs.isEqualEquatableExistential(a: Int(1) as any BinaryInteger & Sendable,
                                                       b: UInt(1) as any BinaryInteger & Sendable))
    
    // TODO: classes
    // https://forums.swift.org/t/comparing-two-any-values-for-equality-is-this-the-simplest-implementation/73816/8
  }
}
