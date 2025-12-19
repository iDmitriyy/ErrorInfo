//
//  ErrorInfoValueVariantTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

@testable import ErrorInfo
import Testing

struct ErrorInfoValueVariantTests {
  private typealias _OptionalAnyValue = ErrorInfo.EquatableOptionalAnyValue
  
  @Test func equality() throws {
    let equalityFunc: (_OptionalAnyValue, _OptionalAnyValue) -> Bool = { $0 == $1 }
    
    
    #expect(equalityFunc(.value(10), .value(10)))
    #expect(!equalityFunc(.value(Int(10)), .value(UInt(10))))
    
    #expect(equalityFunc(.value(10), .value(10 as ErrorInfo.ValueExistential)))
    
    
    #expect(equalityFunc(.value(10), .value(10)))
    
    #expect(!equalityFunc(.value(10),
                          .nilInstance(typeOfWrapped: Int.self)))
    
    #expect(equalityFunc(.nilInstance(typeOfWrapped: Int.self),
                         .nilInstance(typeOfWrapped: Int.self)))
    
    #expect(!equalityFunc(.nilInstance(typeOfWrapped: Int.self),
                          .nilInstance(typeOfWrapped: UInt.self)))
    
    #expect(equalityFunc(.nilInstance(typeOfWrapped: Int.self as (any ErrorInfo.ValueProtocol.Type)),
                         .nilInstance(typeOfWrapped: Int.self)))
  }
}
