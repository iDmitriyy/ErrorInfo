//
//  ValuesForKeyPerfomanceTests.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

@testable import ErrorInfo
import Testing

struct ValuesForKeyPerfomanceTests {
  private let values = (0...1000000).map { $0 as any ErrorInfoValueType }
  
  @Test func initWithSingleValue() {
    let count = 100
    
    if #available(macOS 26.0, *) {
      let values = InlineArray<1000, any ErrorInfoValueType>.init({ index in
        index as any ErrorInfoValueType
      })
      
      let inlineOutput = performMeasuredAction(count: count) {
        InlineArray<1000, any ErrorInfoValueType>.init({ index in
          values[index]
        })
      }
      
      let arrayOutput = performMeasuredAction(count: count) {
        InlineArray<1000, Array<any ErrorInfoValueType>>.init({ index in
          /// get existing value, eliminate costs for casting `index as any ErrorInfoValueType`
          let value = values[index]
          let valueWrappedByArray = [value]
          return valueWrappedByArray
        })
      }
      
      let valuesForKeyOutput = performMeasuredAction(count: count) {
        InlineArray<1000, ValuesForKey<any ErrorInfoValueType>>.init({ index in
          let value = values[index]
          let valueWrappedByValuesForKey = ValuesForKey(element: value)
          return valueWrappedByValuesForKey
        })
      }
      
      // on debug builds:
      // pure InlineArray is ~5x faster than Array
      // ValuesForKey is ~1.5 slower than Array thus heap allocation is eliminated
      // Creation of underlying wrapping enum with a value is surprisingly slower
      print("")
    }
  }
}
