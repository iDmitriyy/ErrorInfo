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
    let count = 10
    
    if #available(macOS 26.0, *) {
      let inlineOutput = performMeasuredAction(count: count) {
        InlineArray<1000, ErrorInfo.ValueExistential>({ index in
          index as ErrorInfo.ValueExistential
        })
      }
      
      let arrayOutput = performMeasuredAction(count: count) {
        InlineArray<1000, Array<ErrorInfo.ValueExistential>>({ index in
          /// get existing value, eliminate costs for casting `index as ErrorInfo.ValueExistential`
          let value = index as ErrorInfo.ValueExistential
          let valueWrappedByArray = [value]
          return valueWrappedByArray
        })
      }
      
      let valuesForKeyOutput = performMeasuredAction(count: count) {
        InlineArray<1000, ValuesForKey<ErrorInfo.ValueExistential>>({ index in
          let value = index as ErrorInfo.ValueExistential
          let valueWrappedByValuesForKey = ValuesForKey(__element: value)
          return valueWrappedByValuesForKey
        })
      }
      
       let durations = VariadicTuple(inlineOutput.duration, arrayOutput.duration, valuesForKeyOutput.duration)
      
      #expect(valuesForKeyOutput.duration <= inlineOutput.duration * 1.55)
      #expect(valuesForKeyOutput.duration <= arrayOutput.duration * 0.27)
      
       print(durations)
    }
  }
  
  @Test func initWithTwoValues() {
    let count = 10
    
    if #available(macOS 26.0, *) {
      let inlineOutput = performMeasuredAction(count: count) {
        InlineArray<1000, (ErrorInfo.ValueExistential, ErrorInfo.ValueExistential)>({ index in
          (index as ErrorInfo.ValueExistential, index as ErrorInfo.ValueExistential)
        })
      }
      
      let arrayOutput = performMeasuredAction(count: count) {
        InlineArray<1000, Array<ErrorInfo.ValueExistential>>({ index in
          /// get existing value, eliminate costs for casting `index as ErrorInfo.ValueExistential`
          let value = index as ErrorInfo.ValueExistential // values[index]
          let valuesWrappedByArray = [value, value]
          return valuesWrappedByArray
        })
      }
      
      let valuesForKeyOutput = performMeasuredAction(count: count) {
        InlineArray<1000, ValuesForKey<ErrorInfo.ValueExistential>>({ index in
          let value = index as ErrorInfo.ValueExistential // values[index]
          let valuesWrappedByValuesForKey = ValuesForKey(__array: NonEmptyArray.init(value, value))
          return valuesWrappedByValuesForKey
        })
      }
      
      // TODO: - test ValuesForKey init with NonEmptyArray of 1 element
      
       let durations = VariadicTuple(inlineOutput.duration, arrayOutput.duration, valuesForKeyOutput.duration)
      
      #expect(valuesForKeyOutput.duration <= inlineOutput.duration * 6)
      #expect(valuesForKeyOutput.duration <= arrayOutput.duration * 1.4)
      
       print(durations)
    }
  }
}
