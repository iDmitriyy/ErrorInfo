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
  
  @Test(.serialized,
        arguments: [(1, true), (2, true), (2, false), (3, true), (3, false)]) // , valueDuplicatePolicy: ValueDuplicatePolicy
  @_transparent
  func `add value`(params: (addedValuesCount: Int, addForDifferentKeys: Bool)) {
    let (addedValuesCount, addForDifferentKeys) = params
    
    if #available(macOS 26.0, *) {
      let measurementsCount = countBase / addedValuesCount
      
      let switchDuration = performMeasuredAction(count: measurementsCount, prepare: {
        make1000EmptyInstances()
      }, measure: { infos in
        for _ in infos.indices {
          switch addedValuesCount {
          case 1:
            emptyFunc0()
          case 2:
            if addForDifferentKeys {
              emptyFunc0()
            } else {
              emptyFunc1()
            }
          case 3:
            if addForDifferentKeys {
              emptyFunc0()
            } else {
              emptyFunc1()
            }
          default: Issue.record("Unexpected key-value pairs count \(addedValuesCount)")
          }
        }
      }).duration
      
      let output = performMeasuredAction(count: measurementsCount, prepare: {
        make1000EmptyInstances()
      }, measure: { infos in
        for index in infos.indices {
          switch addedValuesCount {
          case 1:
            infos[index][.id] = index
          case 2:
            if addForDifferentKeys {
              infos[index][.id] = index
              infos[index][.errorCode] = index
            } else {
              infos[index][.errorCode] = index
              infos[index][.errorCode] = index
            }
          case 3:
            if addForDifferentKeys {
              infos[index][.id] = index
              infos[index][.errorCode] = index
              infos[index][.dataString] = index
            } else {
              infos[index][.errorCode] = index
              infos[index][.errorCode] = index
              infos[index][.errorCode] = index
            }
          default: Issue.record("Unexpected key-value pairs count \(addedValuesCount)")
          }
        }
      })
      
      // 21.32940  10.29380  6.86570
      if addedValuesCount == 1 {
        print(printPrefix, "1000 empty total ", output.preparationsDuration.asString(fractionDigits: 5))
      }
      
      let pluralValue = addedValuesCount == 1 ? "value" : "values"
      print(printPrefix,
            "add \(addedValuesCount) \(pluralValue) for \(addForDifferentKeys ? "different keys" : "same key")",
            (output.duration - switchDuration).asString(fractionDigits: 5))
      
      // print(printPrefix, "\(addedValuesCount) switchDuration ", switchDuration.asString(fractionDigits: 5))
    }
  }
  
  @available(macOS 26.0, *)
  @_transparent
  internal func make1000EmptyInstances() -> InlineArray<1000, ErrorInfo> {
    InlineArray<1000, ErrorInfo>({ _ in ErrorInfo() })
  }
}
