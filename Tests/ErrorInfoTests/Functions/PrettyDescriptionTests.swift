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
    #expect(prettyDescriptionOfOptional(any: input) == input)
  }
  
  @Test func prettyDescriptionForOptionalString() {
    let input: String? = "Hello World"
    #expect(prettyDescriptionOfOptional(any: input) == "Hello World")
  }
  
  @Test func prettyDescriptionForNonOptionalLiteral() {
    #expect(prettyDescriptionOfOptional(any: 10) == "10")
  }
  
  @Test func customStringConvertible() throws {
    let val1: Int = 1
    let expectedOutput = "1"
    
    #expect(prettyDescriptionOfOptional(any: val1) == expectedOutput)
    
    let val1Any: Any = val1 as Any
    #expect(prettyDescriptionOfOptional(any: val1Any) == expectedOutput)
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
    #expect(prettyDescriptionOfOptional(any: singleOptVal) == singleOptValExpectation)
    #expect(prettyDescriptionOfOptional(any: doubleOptVal) == doubleOptValExpectation)
    #expect(prettyDescriptionOfOptional(any: tripleOptVal) == tripleOptValExpectation)
    
    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any
      
      #expect(prettyDescriptionOfOptional(any: singleOptAny) == singleOptValExpectation)
      #expect(prettyDescriptionOfOptional(any: doubleOptAny) == doubleOptValExpectation)
      #expect(prettyDescriptionOfOptional(any: tripleOptAny) == tripleOptValExpectation)
      
      let singleOptAnyAny: Any = (Optional.some(singleOptAny) as Any)
      let doubleOptAnyAny: Any = (Optional.some(doubleOptAny) as Any)
      let tripleOptAnyAny: Any = (Optional.some(tripleOptAny) as Any)
      
      #expect(prettyDescriptionOfOptional(any: singleOptAnyAny) == singleOptValExpectation)
      #expect(prettyDescriptionOfOptional(any: doubleOptAnyAny) == doubleOptValExpectation)
      #expect(prettyDescriptionOfOptional(any: tripleOptAnyAny) == tripleOptValExpectation)
      
      let singleOptOptAnyAny: Any? = (Optional.some(singleOptAny) as Any)
      let doubleOptOptAnyAny: Any? = (Optional.some(doubleOptAny) as Any)
      let tripleOptOptAnyAny: Any? = (Optional.some(tripleOptAny) as Any)
      
      #expect(prettyDescriptionOfOptional(any: singleOptOptAnyAny) == singleOptValExpectation)
      #expect(prettyDescriptionOfOptional(any: doubleOptOptAnyAny) == doubleOptValExpectation)
      #expect(prettyDescriptionOfOptional(any: tripleOptOptAnyAny) == tripleOptValExpectation)
    }
  }
    
  @Test func notCustomStringConvertible() throws {
    let val1: NotCustomStringConvertibleStruct = NotCustomStringConvertibleStruct(id: 1, name: "Name")
    let nativeStringRepr = #"NotCustomStringConvertibleStruct(id: 1, name: Optional("Name"))"#
    
    #expect(String(describing: val1) == nativeStringRepr)
    #expect(prettyDescriptionOfOptional(any: val1) == nativeStringRepr)
    
    do {
      let singleOptAny: Any = val1 as Any
      #expect(prettyDescriptionOfOptional(any: singleOptAny) == nativeStringRepr)
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
      let singleOptValString = prettyDescriptionOfOptional(any: singleOptVal)
      #expect(!singleOptValString.hasPrefix("Optional(") &&
        singleOptValString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 1, name: Optional("Name"))"#))
      
      let doubleOptValString = prettyDescriptionOfOptional(any: doubleOptVal)
      #expect(!doubleOptValString.hasPrefix("Optional(") &&
        doubleOptValString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 2, name: Optional("Name"))"#))
      
      let tripleOptValString = prettyDescriptionOfOptional(any: tripleOptVal)
      #expect(!tripleOptValString.hasPrefix("Optional(") &&
        tripleOptValString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 3, name: Optional("Name"))"#))
    }

    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any

      let singleOptAnyString = prettyDescriptionOfOptional(any: singleOptAny)
      #expect(!singleOptAnyString.hasPrefix("Optional(")
        && singleOptAnyString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 1, name: Optional("Name"))"#))
      
      let doubleOptAnyString = prettyDescriptionOfOptional(any: doubleOptAny)
      #expect(!doubleOptAnyString.hasPrefix("Optional(")
        && doubleOptAnyString.hasSuffix(#"NotCustomStringConvertibleStruct(id: 2, name: Optional("Name"))"#))
      
      let tripleOptAnyString = prettyDescriptionOfOptional(any: tripleOptAny)
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
      #expect(prettyDescriptionOfOptional(any: singleOptVal) == expectedOutput)
      #expect(prettyDescriptionOfOptional(any: doubleOptVal) == expectedOutput)
      #expect(prettyDescriptionOfOptional(any: tripleOptVal) == expectedOutput)
    }

    do {
      let singleOptAny: Any = singleOptVal as Any
      let doubleOptAny: Any = doubleOptVal as Any
      let tripleOptAny: Any = tripleOptVal as Any

      #expect(prettyDescriptionOfOptional(any: singleOptAny) == expectedOutput)
      #expect(prettyDescriptionOfOptional(any: doubleOptAny) == expectedOutput)
      #expect(prettyDescriptionOfOptional(any: tripleOptAny) == expectedOutput)
      
      let singleOptAnyAny: Any = (Optional.some(singleOptAny) as Any)
      let doubleOptAnyAny: Any = (Optional.some(doubleOptAny) as Any)
      let tripleOptAnyAny: Any = (Optional.some(tripleOptAny) as Any)
      
      #expect(prettyDescriptionOfOptional(any: singleOptAnyAny) == expectedOutput)
      #expect(prettyDescriptionOfOptional(any: doubleOptAnyAny) == expectedOutput)
      #expect(prettyDescriptionOfOptional(any: tripleOptAnyAny) == expectedOutput)
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
    #expect(prettyDescriptionOfOptional(any: val) == expectedOutput)
    #expect(prettyDescriptionOfOptional(any: singleOptVal) == expectedOutput)
    #expect(prettyDescriptionOfOptional(any: doubleOptVal) == expectedOutput)
    #expect(prettyDescriptionOfOptional(any: tripleOptVal) == expectedOutput)
    
    #expect(prettyDescriptionOfOptional(any: val as Any) == expectedOutput)
    #expect(prettyDescriptionOfOptional(any: singleOptVal as Any) == expectedOutput)
    #expect(prettyDescriptionOfOptional(any: doubleOptVal as Any) == expectedOutput)
    #expect(prettyDescriptionOfOptional(any: tripleOptVal as Any) == expectedOutput)
  }
}

extension PrettyDescriptionTests {
  /// A structure that does not conform to CustomStringConvertible
  private struct NotCustomStringConvertibleStruct {
    let id: UInt64
    let name: String?
  }
}
