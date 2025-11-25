//
//  IsEqualAnyEqatableTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

@testable import ErrorInfo
import Foundation
import Testing

struct IsEqualAnyEqatableTests {
  @Test func basic() throws {
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1), b: Int(1)) == true)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional(Int(1)), b: Int(1)) == true)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1), b: Optional(Int(1))) == true)
    
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1), b: UInt(1)) == false)
    
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Int>.none, b: Int(1)) == false)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Int(1), b: Optional<Int>.none) == false)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Int>.none, b: Optional<Int>.none) == true)
    
    print("")
    
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Int>.none, b: Optional<String>.none) == false)
    #expect(ErrorInfoFuncs.isEqualAnyEqatable(a: Optional<Int>.none, b: Optional<UInt>.none) == false)
  }
}
