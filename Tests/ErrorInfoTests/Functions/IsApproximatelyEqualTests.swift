//
//  IsApproximatelyEqualTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 29/07/2025.
//

@testable import ErrorInfo
import Foundation
import Testing

struct IsApproximatelyEqualTests {
  @Test func notEquatableObjectsEquality() throws {
    final class RefType {}
    
    let obj1 = RefType()
    let obj2 = RefType()
  }
  
  @Test func equatableObjectsEquality() throws {
    final class RefType {
      let value: Int
      init(value: Int) {
        self.value = value
      }
    }
  }
  
  @Test func equalNumbers() throws {
    ErrorInfoFuncs.isEqualAny("5" as Any, 5 as Any)
    /*
     "5" Int(5)
     Int(5) UInt(5)
     Int(5) Double(5)
     Decimal(5) Double(5)
     */
  }
  
  @Test func equatableValuesEquality() throws {}
  
  @Test func notEquatableValuesEquality() throws {}
  
  @Test func stringsEquality() throws {
    // LATIN SMALL LETTER E WITH ACUTE
    let eLatin = "\u{E9}"
    
    // LATIN SMALL LETTER E and COMBINING ACUTE ACCENT
    let eCombined = "\u{65}\u{301}"
    
    eLatin == eCombined
    eLatin._isIdentical(to: eCombined)
    
    eLatin.hash == eCombined.hash
    eLatin.hashValue == eCombined.hashValue
  }
}

extension IsApproximatelyEqualTests {
  // Custom Equatable struct for testing
  struct TestEquatable: Equatable {
    let value: Int
  }
    
  // Custom class (reference type) for testing
  class TestNonEquatableStringConvertibleClass: CustomStringConvertible {
    let id: Int
    init(id: Int) { self.id = id }
    var description: String { "TestClass id: \(id)" }
  }
    
  @Test func `equatable Integers Equal`() {
    #expect(ErrorInfoFuncs.isEqualAny(5, 5))
    
    #expect(ErrorInfoFuncs.isEqualAny(5 as Any, 5))
    #expect(ErrorInfoFuncs.isEqualAny(5 as Any, 5 as Any))
    
    #expect(ErrorInfoFuncs.isApproximatelyEqualDTypes(a: 5 as AnyObject, b: 5))
    #expect(ErrorInfoFuncs.isEqualAny(5 as AnyObject, 5 as AnyObject))
    
    #expect(ErrorInfoFuncs.isEqualAny(5 as any Equatable, 5))
    #expect(ErrorInfoFuncs.isEqualAny(5 as any Equatable, 5 as any Equatable))
    
    #expect(ErrorInfoFuncs.isEqualAny(5 as any Hashable, 5))
    #expect(ErrorInfoFuncs.isEqualAny(5 as any Hashable, 5 as any Hashable))
    
    #expect(ErrorInfoFuncs.isEqualAny(5 as AnyHashable, 5))
    #expect(ErrorInfoFuncs.isEqualAny(5 as AnyHashable, 5 as AnyHashable))
    
    #expect(ErrorInfoFuncs.isEqualAny(5 as any CustomStringConvertible, 5))
    #expect(ErrorInfoFuncs.isEqualAny(5 as any CustomStringConvertible, 5 as any CustomStringConvertible))
    
    #expect(ErrorInfoFuncs.isEqualAny(5 as any ErrorInfoValueType, 5))
    #expect(ErrorInfoFuncs.isEqualAny(5 as any ErrorInfoValueType, 5 as any ErrorInfoValueType))
    
    // TODO: + Optionaal(5)
    
    // + different types casted `any ErrorInfoValueType` and the passed to isApproximatelyEqualAny fo erasure of Generic type
    
    // #expect(_isOptional(type(of: Optional<Int>(4) as Any).self))
  }
    
  @Test func `equatable Integers NotEqual`() {
    #expect(!ErrorInfoFuncs.isEqualAny(5, 6))
  }
    
  @Test func `equatable Strings Equal`() {
    #expect(ErrorInfoFuncs.isEqualAny("hello", "hello"))
  }
    
  @Test func `equatable Strings NotEqual`() {
    #expect(!ErrorInfoFuncs.isEqualAny("hello", "world"))
  }
    
  @Test func `custom EquatableStruct Equal`() {
    let a = TestEquatable(value: 10)
    let b = TestEquatable(value: 10)
    #expect(ErrorInfoFuncs.isEqualAny(a, b))
  }
    
  @Test func `custom EquatableStruct NotEqual`() {
    let a = TestEquatable(value: 10)
    let b = TestEquatable(value: 11)
    #expect(!ErrorInfoFuncs.isEqualAny(a, b))
  }
    
  @Test func `reference Types With Same Description`() {
    let a = TestNonEquatableStringConvertibleClass(id: 1)
    let b = TestNonEquatableStringConvertibleClass(id: 1)
    // If not Equatable, classes are compared by ===
    #expect(!ErrorInfoFuncs.isEqualAny(a, b))
  }
    
  @Test func `reference Types With Different Description`() {
    let a = TestNonEquatableStringConvertibleClass(id: 1)
    let b = TestNonEquatableStringConvertibleClass(id: 2)
    #expect(!ErrorInfoFuncs.isEqualAny(a, b))
  }
  
  @Test func `non Equatable Values With Same Description`() {
    struct NonEquatable {}
    let a = NonEquatable()
    let b = NonEquatable()
    // Since NonEquatable is neither Equatable nor class with address, string describing will be same (likely type name)
    #expect(ErrorInfoFuncs.isEqualAny(a, b))
  }
  
  @Test func `non Equatable Values With Different Description`() {
    class DiffDesc: CustomStringConvertible {
      let desc: String
      init(desc: String) { self.desc = desc }
      var description: String { desc }
    }
    let a1 = DiffDesc(desc: "foo")
    let a2 = DiffDesc(desc: "foo")
    let b = DiffDesc(desc: "bar")
    
    // RefType instances are compared by === even if the conform to CustomStringConvertible
    
    #expect(!ErrorInfoFuncs.isEqualAny(a1, b))
    #expect(!ErrorInfoFuncs.isEqualAny(a2, b))
    #expect(!ErrorInfoFuncs.isEqualAny(a1, a2))
    
    #expect(ErrorInfoFuncs.isEqualAny(a1, a1))
    #expect(ErrorInfoFuncs.isEqualAny(a2, a2))
    #expect(ErrorInfoFuncs.isEqualAny(b, b))
  }
  
  @Test func `non Equatable non StringConvertible Class`() {
    final class ClassType {
      let value: String
      init(value: String) { self.value = value }
    }
    let a = ClassType(value: "foo")
    let b = ClassType(value: "bar")
    
    #expect(!ErrorInfoFuncs.isEqualAny(a, b))
    #expect(ErrorInfoFuncs.isEqualAny(a, a))
    #expect(ErrorInfoFuncs.isEqualAny(b, b))
  }
  
  @Test func `non Equatable StringConvertible ValueType`() {
    // struct TypeA: CustomStringConvertible { let value: Int }
    // struct TypeB: CustomStringConvertible { let value: Int }
  }
  
  @Test func `non Equatable non StringConvertible ValueType`() {
    // struct TypeA { let value: Int }
    // struct TypeB { let value: Int }
  }
  
  @Test func `mixed Types With Same String Representation`() {
    let a = 123
    let b = "123"
    // Different types are treated as not equal even if they have semantically same meaning
    #expect(!ErrorInfoFuncs.isApproximatelyEqualDTypes(a: a, b: b))
    
    #expect(!ErrorInfoFuncs.isEqualAny(a as Any, b))
    #expect(!ErrorInfoFuncs.isEqualAny(a as Any, b as Any))
    
    #expect(!ErrorInfoFuncs.isApproximatelyEqualDTypes(a: a as AnyObject, b: b))
    #expect(!ErrorInfoFuncs.isEqualAny(a as AnyObject, b as AnyObject))
    
    #expect(!ErrorInfoFuncs.isEqualAny(a as any Equatable, b))
    #expect(!ErrorInfoFuncs.isEqualAny(a as any Equatable, b as any Equatable))
    
    #expect(!ErrorInfoFuncs.isEqualAny(a as any Hashable, b))
    #expect(!ErrorInfoFuncs.isEqualAny(a as any Hashable, b as any Hashable))
    
    #expect(!ErrorInfoFuncs.isEqualAny(a as AnyHashable, b))
    #expect(!ErrorInfoFuncs.isEqualAny(a as AnyHashable, b as AnyHashable))
    
    #expect(!ErrorInfoFuncs.isEqualAny(a as any CustomStringConvertible, b))
    #expect(!ErrorInfoFuncs.isEqualAny(a as any CustomStringConvertible, b as any CustomStringConvertible))
    
    #expect(!ErrorInfoFuncs.isEqualAny(a as any ErrorInfoValueType, b))
    #expect(!ErrorInfoFuncs.isEqualAny(a as any ErrorInfoValueType, b as any ErrorInfoValueType))
    
    // TODO: + Optionaal(b)
  }
}
