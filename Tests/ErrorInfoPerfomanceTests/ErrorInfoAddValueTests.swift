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
  
  
  @Test(.serialized, arguments: [1, 2, 3], 1...3)
  func `add value`(denominator: Int, dd: ClosedRange<Int>) {
    if #available(macOS 26.0, *) {
      let output = performMeasuredAction(count: countBase / denominator) {
        make1000EmptyInstances()
      } measure: { infos in
        for index in infos.indices {
          blackHole(index)
        }
      }
      
      print(printPrefix, "1000 empty total ", output.preparationsDuration.asString(fractionDigits: 5))
      let pluralValue = denominator == 1 ? "value" : "values"
      print(printPrefix, "add \(denominator) \(pluralValue) ", output.duration.asString(fractionDigits: 5))
    }
  }
  
  @Test(.serialized) func `add 1 value`() {
    if #available(macOS 26.0, *) {
      let output = performMeasuredAction(count: countBase) {
        make1000EmptyInstances()
      } measure: { infos in
        for index in infos.indices {
          blackHole(index)
        }
      }
      print(printPrefix, "1000 empty total ", output.preparationsDuration.asString(fractionDigits: 5))
      print(printPrefix, "add 1 value ", output.duration.asString(fractionDigits: 5))
    }
  }
  
  @Test func `add 2 values for different keys`() {
    if #available(macOS 26.0, *) {
      let output = performMeasuredAction(count: countBase / 2) {
        make1000EmptyInstances()
      } measure: { infos in
        for index in infos.indices {
          blackHole(index)
        }
      }
      print(printPrefix, "add 2 values for different keys ", output.duration.asString(fractionDigits: 5))
    }
  }
  
  @Test func `add 2 values for same key`() {
    if #available(macOS 26.0, *) {
      let output = performMeasuredAction(count: countBase / 2) {
        make1000EmptyInstances()
      } measure: { infos in
        for index in infos.indices {
          blackHole(index)
        }
      }
      print(printPrefix, "add 2 values for same key ", output.duration.asString(fractionDigits: 5))
    }
  }
  
  @Test func `add 3 values for different keys`() {
    if #available(macOS 26.0, *) {
      let output = performMeasuredAction(count: countBase / 3) {
        make1000EmptyInstances()
      } measure: { infos in
        for index in infos.indices {
          blackHole(index)
        }
      }
      print(printPrefix, "add 3 values for different keys ", output.duration.asString(fractionDigits: 5))
    }
  }
  
  @Test func `add 3 values for same key`() {
    if #available(macOS 26.0, *) {
      let output = performMeasuredAction(count: countBase / 3) {
        make1000EmptyInstances()
      } measure: { infos in
        for index in infos.indices {
          blackHole(index)
        }
      }
      print(printPrefix, "add 3 values for same key ", output.duration.asString(fractionDigits: 5))
    }
  }
  
  @available(macOS 26.0, *)
  @_transparent
  internal func make1000EmptyInstances() -> InlineArray<1000, ErrorInfo> {
    InlineArray<1000, ErrorInfo>({ _ in [:] })
  }
}
