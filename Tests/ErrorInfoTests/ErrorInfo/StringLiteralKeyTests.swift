//
//  StringLiteralKeyTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

@testable import ErrorInfo
import Testing

struct StringLiteralKeyTests {
  @Test func literalsCombining() throws {
    #expect(desctructured(literal: .id) == ("id", .literalConstant))
    #expect(desctructured(literal: "single_literal_key") == ("single_literal_key", .literalConstant))
    
    #expect(desctructured(literal: .object + .interpolation) == ("object_interpolation", .combinedLiterals))
    #expect(desctructured(literal: "resource" + .url) == ("resource_url", .combinedLiterals))
    #expect(desctructured(literal: .message + "receiver") == ("message_receiver", .combinedLiterals))
    #expect(desctructured(literal: "request" + "status" + "id") == ("request_status_id", .combinedLiterals))
    
    // dynamicMember / keyPath combining
//    #expect(desctructured(literal: .request.resource.id) == ("request_resource_id", .combinedLiterals))
  }
  
  private func desctructured(literal: StringLiteralKey) -> (String, KeyOrigin) {
    (String(describing: literal), literal.keyOrigin)
  }
  
  @Test func hashAndEquality() throws {
    let debugMessage: StringLiteralKey = "debug" + "message"
    #expect(debugMessage.keyOrigin == .combinedLiterals)
    
    // keyOrigin is not used in hashinng / equality checking:
    
    #expect(StringLiteralKey.debugMessage == debugMessage)
    #expect(StringLiteralKey.debugMessage.keyOrigin != debugMessage.keyOrigin)
    #expect(String(describing: StringLiteralKey.debugMessage) == String(describing: debugMessage))
    
    #expect(StringLiteralKey.debugMessage.hashValue == debugMessage.hashValue)
    #expect(StringLiteralKey.debugMessage.hashValue == String(describing: StringLiteralKey.debugMessage).hashValue)
  }
}
