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
    
    let value = integer
    
    ErrorInfoFuncs._typeDesciption(for: value)
    ErrorInfoFuncs._typeDesciptionG(for: value)
    
    print("")
  }
}
