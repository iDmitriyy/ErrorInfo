//
//  PlaygroundTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

@_spi(PerfomanceTesting) import ErrorInfo
import Testing

struct PlaygroundTests {
  @Test func playground() throws {
    let count = 10
    let a = ErrorInfo.OptionalWithTypedNil.value(Int.random(in: 1...1000))
    let output = performMeasuredAction(count: count) {
      //let b = ErrorInfo.OptionalWithTypedNil.value(Int.random(in: 1...1000))
      for index in 1...1_000_000 {
        blackHole(ErrorInfo._Record(_optional: .value(index), keyOrigin: .dynamic))
      }
    }
    
    print("__playground: ", output.duration) // blackHole(()) ~22ms for 10 million calls of empty blackHole(())
    
    // __playground:  65.55454200000001
  }
}
