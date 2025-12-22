//
//  PrettyDescriptionTests.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

@testable import ErrorInfo
import Testing

struct PrettyDescriptionTests {
  @Test func prettyDescriptionForString() {
    let input = "Hello World"
    #expect(unwrappedDescription(of: input) == input)
  }
  
  @Test func prettyDescriptionForOptionalString() {
    let input: String? = "Hello World"
    #expect(unwrappedDescription(of: input) == "Hello World")
  }
  
  @Test func prettyDescriptionForNonOptionalLiteral() {
    #expect(unwrappedDescription(of: 10) == "10")
  }
  
  @Test func customStringConvertible() throws {
    let val1: Int = 1
    let expectedOutput = "1"
    
    #expect(unwrappedDescription(of: val1) == expectedOutput)
    
    let val1Any: Any = val1 as Any
    #expect(unwrappedDescription(of: val1Any) == expectedOutput)
  }
  
  @Test func customStringConvertibleOptionalWithNil() throws {
    let singleOptVal: Int? = nil
    let doubleOptVal: Int?? = nil
    let tripleOptVal: Int??? = nil
    
    let expectedOutput = "nil"
    
    imp_customStringConvertibleOptional(singleOptVal: singleOptVal,
                                        singleOptValExpectation: expectedOutput,
                                        doubleOptVal: doubleOptVal,
                                        doubleOptValExpectation: expectedOutput,
                                        tripleOptVal: tripleOptVal,
                                        tripleOptValExpectation: expectedOutput)
  }
  
  @Test func customStringConvertibleOptionalWithWrappedInt() throws {
    let singleOptVal: Int? = 1
    let doubleOptVal: Int?? = 2
    let tripleOptVal: Int??? = 3
    
    // Check if at some time Swift builtin Optional description will change (if ever)
    #expect(String(describing: singleOptVal) == "Optional(1)")
    #expect(String(describing: doubleOptVal) == "Optional(Optional(2))")
    #expect(String(describing: tripleOptVal) == "Optional(Optional(Optional(3)))")
    
    imp_customStringConvertibleOptional(singleOptVal: singleOptVal,
                                        singleOptValExpectation: "1",
                                        doubleOptVal: doubleOptVal,
                                        doubleOptValExpectation: "2",
                                        tripleOptVal: tripleOptVal,
                                        tripleOptValExpectation: "3")
  }
  
  private func imp_customStringConvertibleOptional(singleOptVal: Int?,
                                                   singleOptValExpectation: String,
                                                   doubleOptVal: Int??,
                                                   doubleOptValExpectation: String,
                                                   tripleOptVal: Int???,
                                                   tripleOptValExpectation: String) {
    #expect(unwrappedDescription(of: singleOptVal) == singleOptValExpectation)
    #expect(unwrappedDescription(of: doubleOptVal) == doubleOptValExpectation)
    #expect(unwrappedDescription(of: tripleOptVal) == tripleOptValExpectation)
    
    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any
      
      #expect(unwrappedDescription(of: singleOptAny) == singleOptValExpectation)
      #expect(unwrappedDescription(of: doubleOptAny) == doubleOptValExpectation)
      #expect(unwrappedDescription(of: tripleOptAny) == tripleOptValExpectation)
      
      let singleOptAnyAny: Any = (Optional.some(singleOptAny) as Any)
      let doubleOptAnyAny: Any = (Optional.some(doubleOptAny) as Any)
      let tripleOptAnyAny: Any = (Optional.some(tripleOptAny) as Any)
      
      #expect(unwrappedDescription(of: singleOptAnyAny) == singleOptValExpectation)
      #expect(unwrappedDescription(of: doubleOptAnyAny) == doubleOptValExpectation)
      #expect(unwrappedDescription(of: tripleOptAnyAny) == tripleOptValExpectation)
      
      let singleOptOptAnyAny: Any? = (Optional.some(singleOptAny) as Any)
      let doubleOptOptAnyAny: Any? = (Optional.some(doubleOptAny) as Any)
      let tripleOptOptAnyAny: Any? = (Optional.some(tripleOptAny) as Any)
      
      #expect(unwrappedDescription(of: singleOptOptAnyAny) == singleOptValExpectation)
      #expect(unwrappedDescription(of: doubleOptOptAnyAny) == doubleOptValExpectation)
      #expect(unwrappedDescription(of: tripleOptOptAnyAny) == tripleOptValExpectation)
    }
  }
    
  @Test func notCustomStringConvertible() throws {
    let val1: NotCustomStringConvertibleStruct = NotCustomStringConvertibleStruct(id: 1, name: "Name")
    let nativeStringRepr = #"NotCustomStringConvertibleStruct(id: 1, name: Optional("Name"))"#
    
    #expect(String(describing: val1) == nativeStringRepr)
    #expect(unwrappedDescription(of: val1) == nativeStringRepr)
    
    do {
      let singleOptAny: Any = val1 as Any
      #expect(unwrappedDescription(of: singleOptAny) == nativeStringRepr)
    }
  }
  
  @Test func notCustomStringConvertibleOptionalWrapped() throws {
    let singleOptVal: NotCustomStringConvertibleStruct? = NotCustomStringConvertibleStruct(id: 1, name: "Name")
    let doubleOptVal: NotCustomStringConvertibleStruct?? = NotCustomStringConvertibleStruct(id: 2, name: "Name")
    let tripleOptVal: NotCustomStringConvertibleStruct??? = NotCustomStringConvertibleStruct(id: 3, name: "Name")
    
    // For a type wrapped in Optional and not conforming to CustomStringConvertible, when converting to a string
    // we get smth like:
    // "Optional(LibraryNameTests.PrettyDescriptionTests.(unknown context at $11144b83c).SomeStruct(id: 1, name: "Name"))"
    // instead of "Optional(SomeStruct(id: 1, name: "Name"))"
    // https://bugs.swift.org/browse/SR-6787?page=com.atlassian.jira.plugin.system.issuetabpanels%3Acomment-tabpanel&showAll=true
            
    // Therefore, we check a bit differently: instead of using XCTAssertEqual, we check that the string does not contain "Optional"
    // and does contain the structure's data
    do {
      let singleOptValString = unwrappedDescription(of: singleOptVal)
      #expect(!singleOptValString.hasPrefix("Optional(") &&
        singleOptValString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 1, name: Optional("Name"))"#))
      
      let doubleOptValString = unwrappedDescription(of: doubleOptVal)
      #expect(!doubleOptValString.hasPrefix("Optional(") &&
        doubleOptValString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 2, name: Optional("Name"))"#))
      
      let tripleOptValString = unwrappedDescription(of: tripleOptVal)
      #expect(!tripleOptValString.hasPrefix("Optional(") &&
        tripleOptValString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 3, name: Optional("Name"))"#))
    }

    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any

      let singleOptAnyString = unwrappedDescription(of: singleOptAny)
      #expect(!singleOptAnyString.hasPrefix("Optional(")
        && singleOptAnyString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 1, name: Optional("Name"))"#))
      
      let doubleOptAnyString = unwrappedDescription(of: doubleOptAny)
      #expect(!doubleOptAnyString.hasPrefix("Optional(")
        && doubleOptAnyString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 2, name: Optional("Name"))"#))
      
      let tripleOptAnyString = unwrappedDescription(of: tripleOptAny)
      #expect(!tripleOptAnyString.hasPrefix("Optional(")
        && tripleOptAnyString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 3, name: Optional("Name"))"#))
    }
  }
  
  @Test func notCustomStringConvertibleOptionalNil() throws {
    let singleOptVal: NotCustomStringConvertibleStruct? = nil
    let doubleOptVal: NotCustomStringConvertibleStruct?? = nil
    let tripleOptVal: NotCustomStringConvertibleStruct??? = nil
    
    let expectedOutput = "nil"
    do {
      #expect(unwrappedDescription(of: singleOptVal) == expectedOutput)
      #expect(unwrappedDescription(of: doubleOptVal) == expectedOutput)
      #expect(unwrappedDescription(of: tripleOptVal) == expectedOutput)
    }

    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any

      #expect(unwrappedDescription(of: singleOptAny) == expectedOutput)
      #expect(unwrappedDescription(of: doubleOptAny) == expectedOutput)
      #expect(unwrappedDescription(of: tripleOptAny) == expectedOutput)
      
      let singleOptAnyAny: Any = (Optional.some(singleOptAny) as Any)
      let doubleOptAnyAny: Any = (Optional.some(doubleOptAny) as Any)
      let tripleOptAnyAny: Any = (Optional.some(tripleOptAny) as Any)
      
      #expect(unwrappedDescription(of: singleOptAnyAny) == expectedOutput)
      #expect(unwrappedDescription(of: doubleOptAnyAny) == expectedOutput)
      #expect(unwrappedDescription(of: tripleOptAnyAny) == expectedOutput)
    }
  }
  
  @Test func prettyDescriptionForCustomDescription() {
    struct CustomStringConvertibleStruct: CustomStringConvertible {
      var description: String { "Custom Description" }
    }
    
    let val = CustomStringConvertibleStruct()
    let singleOptVal: CustomStringConvertibleStruct? = val
    let doubleOptVal: CustomStringConvertibleStruct?? = val
    let tripleOptVal: CustomStringConvertibleStruct??? = val
    
    let expectedOutput = "Custom Description"
    #expect(unwrappedDescription(of: val) == expectedOutput)
    #expect(unwrappedDescription(of: singleOptVal) == expectedOutput)
    #expect(unwrappedDescription(of: doubleOptVal) == expectedOutput)
    #expect(unwrappedDescription(of: tripleOptVal) == expectedOutput)
    
    #expect(unwrappedDescription(of: val as Any) == expectedOutput)
    #expect(unwrappedDescription(of: singleOptVal as Any) == expectedOutput)
    #expect(unwrappedDescription(of: doubleOptVal as Any) == expectedOutput)
    #expect(unwrappedDescription(of: tripleOptVal as Any) == expectedOutput)
  }
}

extension PrettyDescriptionTests {
  /// A structure that does not conform to CustomStringConvertible
  private struct NotCustomStringConvertibleStruct {
    let id: UInt64
    let name: String?
  }
}
