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
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1), b: Int(1)) == true)
    
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: Int(1), b: UInt(1)) == false)
    #expect(ErrorInfoFuncs.isEqualEqatableExistential(a: UInt(1), b: Int(1)) == false)
  }
}
