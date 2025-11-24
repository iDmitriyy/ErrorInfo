//
//  TypeDesciptionTests.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 09/10/2025.
//

@testable import ErrorInfo
import Testing

struct TypeDesciptionTests {
  @Test func checkValueTypes() {
    let integer: Int = 10
    let integerOptional: Int? = 10
    
    let integerAnyEIV: any ErrorInfoValueType = 10
    let integerOptionalAnyEIV: (any ErrorInfoValueType)? = 10
        
    descr(of: integer)
    descr(of: integerOptional)
    
    descr(of: integerAnyEIV)
    descr(of: integerOptionalAnyEIV)
    
    print("")
  }
  
  @Test func objectTypesInstances() {
    let testClass: TestClass = TestClass()
    let testClassOptional: TestClass? = TestClass()
    
    let testSubClass: TestSubClass = TestSubClass()
    let testSubClassOptional: TestSubClass? = TestSubClass()
    
    let testSubClassAsParent: TestClass = TestSubClass()
    let testSubClassAsParentOptional: TestClass? = TestSubClass()
    
    let testClassAsAnyObject: AnyObject = TestClass()
    let testClassOptionalAnyObject: AnyObject? = TestClass()
    
    let testSubClassAnyObject: AnyObject = TestSubClass()
    let testSubClassOptionalObject: AnyObject? = TestSubClass()
    print("")
    
    descr(of: testClass)
    descr(of: testClassOptional)
    print("")
    
    descr(of: testSubClass)
    descr(of: testSubClassOptional)
    print("")
    
    descr(of: testSubClassAsParent)
    descr(of: testSubClassAsParentOptional)
    print("")
    
    descr(of: testClassAsAnyObject)
    descr(of: testClassOptionalAnyObject)
    print("")
    
    descr(of: testSubClassAnyObject)
    descr(of: testSubClassOptionalObject)
  }
  
  @Test func objectTypesNil() {
    let testClassOptional: TestClass? = nil
    let testSubClassOptional: TestSubClass? = nil
    
    let testClassOptionalAsAnyObject: AnyObject? = Optional<TestClass>.none
    let testSubClassOptionalAsAnyObject: AnyObject? = Optional<TestSubClass>.none
  }
    
  func descr<T>(of value: T) {
    _ = value
    print("descr<T> \(T.self)")
  }
  
  func descr<T>(of value: T?) {
    _ = value
//
    if let value {
      print("descr<T?> \(type(of: value))?")
    } else {
      print("descr<T?> \(T.self)?")
    }
  }
  
  func descr<T: AnyObject>(of value: T) {
    _ = value
    print("descr<objT> \(type(of: value))")
  }
  
  func descr<T: AnyObject>(of value: T?) {
    _ = value
//    print("descr<objT?> \(T.self)?")
    if let value {
      print("descr<objT?> \(type(of: value))?")
    } else {
      print("descr<objT?> \(T.self)?")
    }
  }
  
  @Test func typesEquality() {
    #expect(Int.self == Int.self)
    
    let a1 = (Int.self as Any.Type) == Int.self
    #expect(a1)
    
    let a2 = (Int.self as (any ErrorInfoValueType.Type)) == Int.self
    #expect(a2)
    
    let a3 = (Int.self as (any ErrorInfoValueType.Type)) == (Int.self as Any.Type)
    #expect(a3)
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
