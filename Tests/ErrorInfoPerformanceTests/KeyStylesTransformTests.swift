//
//  KeyStylesTransformTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 12/12/2025.
//

import ErrorInfo
import Testing

struct KeyStylesTransformTests {
  @Test func playground() throws {
    let count = 10
    let output = performMeasuredAction(count: count) {
      for index in 1...1_000_000 {
        blackHole(ErrorInfoFuncs.fromAnyStyleToPascalCased(string: "error_message"))
      }
    }
    
    print("__keyStyles: ", output.duration) // it takes ~22ms for 10 million of calls of empty blackHole(())
  }
}

extension KeyStylesTransformTests {
  private static let keys: [String] = [
    "errorCode",
    "error_code",
    "errorMessage",
    "error_message",
    "timestamp",
    "timestamp",
    "errorDescription",
    "error_description",
    "requestId",
    "request_id",
    "userId",
    "user_id",
    "fileName",
    "file_name",
    "lineNumber",
    "line_number",
    "functionName",
    "function_name",
    "stackTrace",
    "stack_trace",
    "httpStatusCode",
    "http_status_code",
  ]
}
