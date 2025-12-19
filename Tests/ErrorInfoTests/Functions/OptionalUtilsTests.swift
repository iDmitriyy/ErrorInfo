//
//  OptionalUtilsTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 16/12/2025.
//

@testable import ErrorInfo
import Testing

struct OptionalUtilsTests {
  // `expectedTypeAny` is passed when exact type can not be determined.
  // `(nil as Int?) as Any?` is equivalent to (`nil as Any?`), specific type can't be extracted from it because nil
  // represents the absence of a value
  private let expectedTypeAny = Any.self
  
  @Test func basic() throws {
    checkIsValue(wrappedValue: 5, expectedUnwrappedValue: 5)
    checkIsValue(wrappedValue: 5 as Any, expectedUnwrappedValue: 5)
    checkIsValue(wrappedValue: 5 as Any?, expectedUnwrappedValue: 5)
    checkIsValue(wrappedValue: (5 as Any?) as Any, expectedUnwrappedValue: 5)
    
    // 1.
    checkIsValue(wrappedValue: 5 as Int?, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: nil as Int?, expectedType: Int.self)
    
    checkIsValue(wrappedValue: (5 as Int?) as Any, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: (nil as Int?) as Any, expectedType: Int.self)
    
    checkIsValue(wrappedValue: (5 as Int?) as Any?, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: (nil as Int?) as Any?, expectedType: expectedTypeAny)
    
    checkIsValue(wrappedValue: ((5 as Int?) as Any?) as Any, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: ((nil as Int?) as Any?) as Any, expectedType: expectedTypeAny)
    
    checkIsValue(wrappedValue: ((5 as Int?) as Any) as Any?, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: ((nil as Int?) as Any) as Any?, expectedType: Int.self)
        
    // 2.
    checkIsValue(wrappedValue: Int??.some(.some(5)), expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: Int??.some(.none), expectedType: Int.self)
    checkIsNil(wrappedValue: Int??.none, expectedType: Int.self)
    
    checkIsValue(wrappedValue: Int??.some(.some(5)) as Any, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: Int??.some(.none) as Any, expectedType: Int.self)
    checkIsNil(wrappedValue: Int??.none as Any, expectedType: Int.self)
    
    checkIsValue(wrappedValue: Int??.some(.some(5)) as Any?, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: Int??.some(.none) as Any?, expectedType: Int.self)
    checkIsNil(wrappedValue: Int??.none as Any?, expectedType: expectedTypeAny)
    
    checkIsValue(wrappedValue: (Int??.some(.some(5)) as Any?) as Any, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: (Int??.some(.none) as Any?) as Any, expectedType: Int.self)
    checkIsNil(wrappedValue: (Int??.none as Any?) as Any, expectedType: expectedTypeAny)
    
    checkIsValue(wrappedValue: (Int??.some(.some(5)) as Any) as Any?, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: (Int??.some(.none) as Any) as Any?, expectedType: Int.self)
    checkIsNil(wrappedValue: (Int??.none as Any) as Any?, expectedType: Int.self)
    
    // 3.
    checkIsValue(wrappedValue: Any???.some(.some(.some(5 as Any))), expectedUnwrappedValue: 5)
    checkIsValue(wrappedValue: Int???.some(.some(.some(5))), expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: Int???.some(.some(.none)), expectedType: Int.self)
    checkIsNil(wrappedValue: Int???.some(.none), expectedType: Int.self)
    checkIsNil(wrappedValue: Int???.none, expectedType: Int.self)
    
    checkIsValue(wrappedValue: Any???.some(.some(.some(5 as Any))) as Any, expectedUnwrappedValue: 5)
    checkIsValue(wrappedValue: Int???.some(.some(.some(5))) as Any, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: Int???.some(.some(.none)) as Any, expectedType: Int.self)
    checkIsNil(wrappedValue: Int???.some(.none) as Any, expectedType: Int.self)
    checkIsNil(wrappedValue: Int???.none as Any, expectedType: Int.self)
    
    checkIsValue(wrappedValue: Any???.some(.some(.some(5 as Any))) as Any?, expectedUnwrappedValue: 5)
    checkIsValue(wrappedValue: Int???.some(.some(.some(5))) as Any?, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: Int???.some(.some(.none)) as Any?, expectedType: Int.self)
    checkIsNil(wrappedValue: Int???.some(.none) as Any?, expectedType: Int.self)
    checkIsNil(wrappedValue: Int???.none as Any?, expectedType: expectedTypeAny)
    
    checkIsValue(wrappedValue: (Any???.some(.some(.some(5 as Any))) as Any?) as Any, expectedUnwrappedValue: 5)
    checkIsValue(wrappedValue: (Int???.some(.some(.some(5))) as Any?) as Any, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: (Int???.some(.some(.none)) as Any?) as Any, expectedType: Int.self)
    checkIsNil(wrappedValue: (Int???.some(.none) as Any?) as Any, expectedType: Int.self)
    checkIsNil(wrappedValue: (Int???.none as Any?) as Any, expectedType: expectedTypeAny)
    
    checkIsValue(wrappedValue: (Any???.some(.some(.some(5 as Any))) as Any) as Any?, expectedUnwrappedValue: 5)
    checkIsValue(wrappedValue: (Int???.some(.some(.some(5))) as Any) as Any?, expectedUnwrappedValue: 5)
    checkIsNil(wrappedValue: (Int???.some(.some(.none)) as Any) as Any?, expectedType: Int.self)
    checkIsNil(wrappedValue: (Int???.some(.none) as Any) as Any?, expectedType: Int.self)
    checkIsNil(wrappedValue: (Int???.none as Any) as Any?, expectedType: Int.self)
  }
  
  // MARK: - Reusable funcs
  
  private func checkIsValue<Value, RawValue>(wrappedValue: Value,
                                             expectedUnwrappedValue: RawValue,
                                             line: Int = #line,
                                             column: Int = #column) {
    let location = SourceLocation(fileID: #fileID, filePath: #filePath, line: line, column: column)
    let expectedType = RawValue.self
    
    checkTypeOfWrapped(wrappedValue: wrappedValue, expectedType: expectedType, location: location)
    
    let flattenedOptional = ErrorInfoFuncs.flattenOptional(any: wrappedValue)
    switch flattenedOptional {
    case .value(let any):
      #expect(type(of: any) == expectedType.self, sourceLocation: location)
      #expect("\(any)" == "\(expectedUnwrappedValue)", sourceLocation: location)
      
    case .nilInstance:
      Issue.record("Unexpected nil value", sourceLocation: location)
    }
  }
  
  private func checkIsNil<Value, T>(wrappedValue: Value,
                                    expectedType: T.Type,
                                    line: Int = #line,
                                    column: Int = #column) {
    let location = SourceLocation(fileID: #fileID, filePath: #filePath, line: line, column: column)
    
    checkTypeOfWrapped(wrappedValue: wrappedValue, expectedType: expectedType, location: location)
    
    let flattenedOptional = ErrorInfoFuncs.flattenOptional(any: wrappedValue)
    switch flattenedOptional {
    case .value(let any):
      Issue.record("Unexpected value \(any), nil is expected", sourceLocation: location)
      
    case .nilInstance(let wrappedType):
      let isExpectedWrappedType = wrappedType == expectedType
      #expect(isExpectedWrappedType, "type associated with nil not equal to expected", sourceLocation: location)
    }
  }
  
  private func checkTypeOfWrapped<Value, T>(wrappedValue: Value, expectedType: T.Type, location: SourceLocation) {
    let typeOfWrapped = ErrorInfoFuncs.typeOfWrapped(any: wrappedValue)
    
    let isExpectedTypeOfWrapped = typeOfWrapped == expectedType
    #expect(isExpectedTypeOfWrapped, "type not equal to expected", sourceLocation: location)
    
    #expect("\(typeOfWrapped)" == "\(expectedType)", "string interpolation not equal", sourceLocation: location)
  }
}
