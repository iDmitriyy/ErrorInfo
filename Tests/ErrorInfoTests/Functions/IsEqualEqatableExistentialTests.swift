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
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1), b: Int(1)) == true)
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1),
                                                      b: Int(1) as any ErrorInfoValueType) == true)
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1) as any ErrorInfoValueType,
                                                      b: Int(1)) == true)
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1) as any ErrorInfoValueType,
                                                      b: Int(1) as any ErrorInfoValueType) == true)
    
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1),
                                                      b: Int(1) as any BinaryInteger & Sendable) == true)
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1) as any BinaryInteger & Sendable,
                                                      b: Int(1)) == true)
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1) as any BinaryInteger & Sendable,
                                                      b: Int(1) as any BinaryInteger & Sendable) == true)
    
    // Not Equal types
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1),
                                                      b: UInt(1)) == false)
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: UInt(1),
                                                      b: Int(1)) == false)
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1) as any ErrorInfoValueType,
                                                      b: UInt(1)) == false)
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: UInt(1) as any ErrorInfoValueType,
                                                      b: Int(1)) == false)
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1) as any ErrorInfoValueType,
                                                      b: UInt(1) as any ErrorInfoValueType) == false)
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1) as any BinaryInteger & Sendable,
                                                      b: UInt(1)) == false)
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: UInt(1) as any BinaryInteger & Sendable,
                                                      b: Int(1)) == false)
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1) as any BinaryInteger & Sendable,
                                                      b: UInt(1) as any BinaryInteger & Sendable) == false)
    
    // TODO: classes
    // https://forums.swift.org/t/comparing-two-any-values-for-equality-is-this-the-simplest-implementation/73816/8
  }
}
