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
    let output = performMeasuredAction(count: count) {
      for index in 1...1_000_000 {
        blackHole(index)
      }
    }
    
    print("__playground: ", output.duration) // blackHole(()) ~22ms for 10 million calls of empty blackHole(())
    
    // __playground:  65.55454200000001
  }
}
