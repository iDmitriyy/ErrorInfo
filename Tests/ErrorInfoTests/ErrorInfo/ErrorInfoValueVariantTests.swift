//
//  ErrorInfoValueVariantTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

@testable import ErrorInfo
import Testing

struct ErrorInfoValueVariantTests {
  typealias Variant = ErrorInfo._Optional
  
  @Test func equality() async throws {
    #expect(Variant.isApproximatelyEqual(lhs: .value(10), rhs: .value(10)))
    #expect(!Variant.isApproximatelyEqual(lhs: .value(Int(10)), rhs: .value(UInt(10))))
    
    #expect(Variant.isApproximatelyEqual(lhs: .value(10), rhs: .value(10 as any ErrorInfoValueType)))
    
    
    #expect(Variant.isApproximatelyEqual(lhs: .value(10), rhs: .value(10)))
    
    #expect(!Variant.isApproximatelyEqual(lhs: .value(10),
                                         rhs: .nilInstance(typeOfWrapped: Int.self)))
    
    #expect(Variant.isApproximatelyEqual(lhs: .nilInstance(typeOfWrapped: Int.self),
                                         rhs: .nilInstance(typeOfWrapped: Int.self)))
    
    #expect(!Variant.isApproximatelyEqual(lhs: .nilInstance(typeOfWrapped: Int.self),
                                         rhs: .nilInstance(typeOfWrapped: UInt.self)))
    
    #expect(Variant.isApproximatelyEqual(lhs: .nilInstance(typeOfWrapped: Int.self as any ErrorInfoValueType.Type),
                                         rhs: .nilInstance(typeOfWrapped: Int.self)))
  }
}
