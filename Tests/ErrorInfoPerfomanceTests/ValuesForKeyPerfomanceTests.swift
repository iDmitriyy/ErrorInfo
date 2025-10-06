//
//  ValuesForKeyPerfomanceTests.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

// @testable
@_spi(Testing) import ErrorInfo
import Testing

// !rewrite
struct ValuesForKeyPerfomanceTests {
  @Test func initWithSingleValue() {
    let count = 10
    
    if #available(macOS 26.0, *) {
      let inlineOutput = performMeasuredAction(count: count) {
        InlineArray<1000, any ErrorInfoValueType>({ index in
          index as any ErrorInfoValueType
        })
      }
      
      let arrayOutput = performMeasuredAction(count: count) {
        InlineArray<1000, Array<any ErrorInfoValueType>>({ index in
          /// get existing value, eliminate costs for casting `index as any ErrorInfoValueType`
          let value = index as any ErrorInfoValueType
          let valueWrappedByArray = [value]
          return valueWrappedByArray
        })
      }
      
      let valuesForKeyOutput = performMeasuredAction(count: count) {
        InlineArray<1000, ValuesForKey<any ErrorInfoValueType>>({ index in
          let value = index as any ErrorInfoValueType
          let valueWrappedByValuesForKey = ValuesForKey(__element: value)
          return valueWrappedByValuesForKey
        })
      }
      
      // let durations = VariadicTuple(inlineOutput.duration, arrayOutput.duration, valuesForKeyOutput.duration)
      
      #expect(valuesForKeyOutput.duration <= inlineOutput.duration * 1.55)
      #expect(valuesForKeyOutput.duration <= arrayOutput.duration * 0.3)
      
      // print(durations)
    }
  }
  
  @Test func initWithTwoValues() {
    let count = 10
    
    if #available(macOS 26.0, *) {
      let inlineOutput = performMeasuredAction(count: count) {
        InlineArray<1000, (any ErrorInfoValueType, any ErrorInfoValueType)>({ index in
          (index as any ErrorInfoValueType, index as any ErrorInfoValueType)
        })
      }
      
      let arrayOutput = performMeasuredAction(count: count) {
        InlineArray<1000, Array<any ErrorInfoValueType>>({ index in
          /// get existing value, eliminate costs for casting `index as any ErrorInfoValueType`
          let value = index as any ErrorInfoValueType // values[index]
          let valuesWrappedByArray = [value, value]
          return valuesWrappedByArray
        })
      }
      
      let valuesForKeyOutput = performMeasuredAction(count: count) {
        InlineArray<1000, ValuesForKey<any ErrorInfoValueType>>({ index in
          let value = index as any ErrorInfoValueType // values[index]
          let valuesWrappedByValuesForKey = ValuesForKey(__array: [value, value])
          return valuesWrappedByValuesForKey
        })
      }
      
      // let durations = VariadicTuple(inlineOutput.duration, arrayOutput.duration, valuesForKeyOutput.duration)
      
      #expect(valuesForKeyOutput.duration <= inlineOutput.duration * 6)
      #expect(valuesForKeyOutput.duration <= arrayOutput.duration * 1.1)
      
      // print(durations)
    }
  }
}
