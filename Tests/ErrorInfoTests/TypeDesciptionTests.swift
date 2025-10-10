//
//  TypeDesciptionTests.swift
//  ErrorInfo
//
//  Created by tmp on 09/10/2025.
//

@testable import ErrorInfo
import Testing

struct TypeDesciptionTests {
  
  
  @Test func checkTypes() {
    let integer: Int = 10
    let anyErrorInfoInteger: any ErrorInfoValueType = 10
    let optionalAnyErrorInfoInteger: (any ErrorInfoValueType)? = 10
    
    let value = optionalAnyErrorInfoInteger
    
    ErrorInfoFuncs._typeDesciption(for: value)
    
    ErrorInfoFuncs._typeDesciption(for: integer)
    ErrorInfoFuncs._typeDesciption(for: anyErrorInfoInteger)
    ErrorInfoFuncs._typeDesciption(for: optionalAnyErrorInfoInteger)
    
    print("")
  }
}

extension TypeDesciptionTests {
  private class TestClass {}
  private class TestSubClass {}
}
