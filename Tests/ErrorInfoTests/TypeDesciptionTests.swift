//
//  TypeDesciptionTests.swift
//  ErrorInfo
//
//  Created by tmp on 09/10/2025.
//

@testable import ErrorInfo
import Testing

struct TypeDesciptionTests {
  @Test func checkValueTypes() {
    let integer: Int = 10
    let integerOptional: Int? = 10
    
    let integerAnyEIV: any ErrorInfoValueType = 10
    let integerOptionalAnyEIV: (any ErrorInfoValueType)? = 10
    
    ErrorInfoFuncs._typeDesciption(for: integer)
    ErrorInfoFuncs._typeDesciption(for: integerOptional)
    
    print("")
  }
  
  @Test func objectTypesInstances() {
    let testClass: TestClass = TestClass()
    let testClassOptional: TestClass? = TestClass()
    
    let testSubClass: TestSubClass = TestSubClass()
    let testSubClassOptional: TestSubClass? = TestSubClass()
    
    let testClassAsAnyObject: AnyObject = TestClass()
    let testClassOptionalAnyObject: AnyObject? = TestClass()
    
    let testSubClassAsAnyObject: AnyObject = TestSubClass()
    let testSubClassOptionalAnyObject: AnyObject? = TestSubClass()
  }
  
  @Test func objectTypesNil() {
    let testClassOptional: TestClass? = nil
    let testSubClassOptional: TestSubClass? = nil
    
    let testClassOptionalAsAnyObject: AnyObject? = Optional<TestClass>.none
    let testSubClassOptionalAsAnyObject: AnyObject? = Optional<TestSubClass>.none
  }
}

extension TypeDesciptionTests {
  private class TestClass {}
  private final class TestSubClass: TestClass {}
  private struct TestStruct {}
}

extension TypeDesciptionTests {
  // Types that conform to ErrorInfoValueType
  
  private class TestClassEIV: @unchecked Sendable, Equatable, CustomStringConvertible {
    let value: Int = 10
    
    var description: String { "value: \(value)" }
    
    static func == (lhs: TypeDesciptionTests.TestClassEIV, rhs: TypeDesciptionTests.TestClassEIV) -> Bool {
      lhs.value == rhs.value
    }
  }
  
  private final class TestSubClassEIV: TestClass {}
  
  private struct TestStructEIV: ErrorInfoValueType {
    let value: Int = 10
    
    var description: String { "value: \(value)" }
  }
}
