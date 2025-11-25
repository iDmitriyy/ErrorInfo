//
//  ErronInfoLiteralKeyTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

@testable import ErrorInfo
import Testing

struct ErronInfoLiteralKeyTests {
  @Test func basic() throws {
    #expect(stringOf(literal: .object + .interpolation) == "object_interpolation")
    #expect(stringOf(literal: "resource" + .url) == "resource_url")
    #expect(stringOf(literal: .message + "receiver") == "message_receiver")
    #expect(stringOf(literal: "status" + "id") == "status_id")
  }
  
  private func stringOf(literal: ErronInfoLiteralKey) -> String {
    String(describing: literal)
  }
}
