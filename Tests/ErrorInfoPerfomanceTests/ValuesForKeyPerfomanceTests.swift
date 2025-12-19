//
//  ValuesForKeyPerfomanceTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

@_spi(PerfomanceTesting) import ErrorInfo
import NonEmpty
import Testing

// !rewrite
struct ValuesForKeyPerfomanceTests {
  /// Typically ErrorInfo has 1 value for key
  @Test func initWithSingleValue() {
    let count = 50
    
    if #available(macOS 26.0, *) {
      let inlineOutput = performMeasuredAction(count: count) {
        InlineArray<1000, InlineArray<1, Int>>({ index in
          [index]
        })
      }
      
      let arrayOutput = performMeasuredAction(count: count) {
        InlineArray<1000, Array<Int>>({ index in
          /// get existing value, eliminate costs for casting `index as ErrorInfo.ValueExistential`
          let value = index // as ErrorInfo.ValueExistential
          let valueWrappedByArray = [value]
          return valueWrappedByArray
        })
      }
      
      let valuesForKeyOutput = performMeasuredAction(count: count) {
        InlineArray<1000, ValuesForKey<Int>>({ index in
          let value = index // as ErrorInfo.ValueExistential
          let valueWrappedByValuesForKey = ValuesForKey(__element: value)
          return valueWrappedByValuesForKey
        })
      }
      
      let durations = VariadicTuple(inlineOutput.duration, arrayOutput.duration, valuesForKeyOutput.duration)
      
      #expect(valuesForKeyOutput.duration <= inlineOutput.duration * 1.55)
      #expect(valuesForKeyOutput.duration <= arrayOutput.duration / 19)
      
      print("__initWithSingleValue: ", durations)
    }
  }
  
  @Test func initWithTwoValues() {
    let count = 10
    
    if #available(macOS 26.0, *) {
      let inlineOutput = performMeasuredAction(count: count) {
        InlineArray<1000, InlineArray<2, Int>>({ index in
          [index, index]
        })
      }
      
      let arrayOutput = performMeasuredAction(count: count) {
        InlineArray<1000, Array<Int>>({ index in
          /// get existing value, eliminate costs for casting `index as ErrorInfo.ValueExistential`
          let valuesWrappedByArray = [index, index]
          return valuesWrappedByArray
        })
      }
      
      let valuesForKeyOutput = performMeasuredAction(count: count) {
        InlineArray<1000, ValuesForKey<Int>>({ index in
          let valuesWrappedByValuesForKey = ValuesForKey(__array: NonEmptyArray(base: [index, index])!)
          return valuesWrappedByValuesForKey
        })
      }
      
      // TODO: - test ValuesForKey init with NonEmptyArray of 1 element
      
      let durations = VariadicTuple(inlineOutput.duration, arrayOutput.duration, valuesForKeyOutput.duration)
      
      #expect(valuesForKeyOutput.duration <= inlineOutput.duration * 15)
      #expect(valuesForKeyOutput.duration <= arrayOutput.duration)
      
      print("__initWithTwoValues: ", durations)
    }
  }
}
