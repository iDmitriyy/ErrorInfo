//
//  ErrorInfoAddValueTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/12/2025.
//

import ErrorInfo
import NonEmpty
import Testing

struct ErrorInfoAddValueTests {
  private let countBase: Int = 10000
  private let printPrefix = "____addValue: "
  
  
  @Test(.serialized, arguments: [1, 2, 3])
  func `add value`(denominator: Int) {
    if #available(macOS 26.0, *) {
      let output = performMeasuredAction(count: countBase / denominator) {
        make1000EmptyInstances()
      } measure: { infos in
        for index in infos.indices {
          blackHole(index)
        }
      }
      
      if denominator == 1 {
        print(printPrefix, "1000 empty total ", output.preparationsDuration.asString(fractionDigits: 5))
      } // 1000 empty total  31.05566
      // 694.95659-696  6432 6441 6388  .
      let pluralValue = denominator == 1 ? "value" : "values"
      print(printPrefix, "add \(denominator) \(pluralValue) ", output.duration.asString(fractionDigits: 5))
    }
  }
  
  @available(macOS 26.0, *)
  @_transparent
  internal func make1000EmptyInstances() -> InlineArray<1000, ErrorInfo> {
    InlineArray<1000, ErrorInfo>({ _ in ErrorInfo() })
  }
}
