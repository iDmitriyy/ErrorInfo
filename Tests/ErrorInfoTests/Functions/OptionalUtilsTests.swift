//
//  OptionalUtilsTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

@testable import ErrorInfo
import Testing

struct OptionalUtilsTests {
  @Test func basic() throws {
    do {
      let integer: Int = 5
      
      let typeOfWrapped = ErrorInfoFuncs.typeOfWrapped(any: integer)
      let flattenedOptional = ErrorInfoFuncs.flattenOptional(any: integer)
      
      let isExpectedTypeOfWrapped = typeOfWrapped == Int.self
      #expect(isExpectedTypeOfWrapped)
      #expect("\(typeOfWrapped)" == "Int")
      
      switch flattenedOptional {
      case .value(let any):
        #expect(type(of: any) == Int.self)
        #expect("\(any)" == "\(integer)")
      case .nilInstance:
        Issue.record("Unexpected nil value")
      }
    }
    
    //    print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Int>>>.some(.some(.some(5)))))
    //    print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Int>>>.some(.some(.none))))
    //    print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Int>>>.some(.none)))
    //    print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Int>>>.none))
    
    //    let value = Optional(Optional(0)) as Any
        let value = 4 // Optional<Optional<Optional<Int>>>.some(.some(.some(5)))
    
        do {
          let typeErasedString: Any = ""
          let typeErasedOptional: Any? = typeErasedString
          let any = typeErasedOptional as Any
          
    //      print("___ type: ", typeOfWrapped(any: typeErasedString))
    //      print("___ type: ", typeOfWrapped(any: typeErasedOptional))
    //      print("___ type: ", typeOfWrapped(any: any))
          
    //      print("___ type: ", typeOfWrapped(any: Optional<Any>.some("")))
          
    //      print("___ type: ", typeOfWrapped(any: Optional<Any>.some("")))
    //      print("___ type: ", typeOfWrapped(any: Optional<Optional<Optional<Any>>>.some(.some(.some("" as Any)))))
        }
  }
}
