//
//  ErrorInfoValueVariantTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

@testable import ErrorInfo
import Testing

struct ErrorInfoValueVariantTests {
  private typealias _Optional = ErrorInfo.OptionalWithTypedNil
  
  @Test func equality() async throws {
    let equalityFunc: (_Optional, _Optional) -> Bool = { $0 == $1 }
    
    
    #expect(equalityFunc(.value(10), .value(10)))
    #expect(!equalityFunc(.value(Int(10)), .value(UInt(10))))
    
    #expect(equalityFunc(.value(10), .value(10 as any ErrorInfoValueType)))
    
    
    #expect(equalityFunc(.value(10), .value(10)))
    
    #expect(!equalityFunc(.value(10),
                          .nilInstance(typeOfWrapped: Int.self)))
    
    #expect(equalityFunc(.nilInstance(typeOfWrapped: Int.self),
                         .nilInstance(typeOfWrapped: Int.self)))
    
    #expect(!equalityFunc(.nilInstance(typeOfWrapped: Int.self),
                          .nilInstance(typeOfWrapped: UInt.self)))
    
    #expect(equalityFunc(.nilInstance(typeOfWrapped: Int.self as any ErrorInfoValueType.Type),
                         .nilInstance(typeOfWrapped: Int.self)))
  }
}
