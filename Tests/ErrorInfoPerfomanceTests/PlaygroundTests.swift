//
//  PlaygroundTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

@_spi(PerfomanceTesting) import ErrorInfo
import Foundation
import Testing

struct PlaygroundTests {
  @Test func playground() throws {
    let count = 10
    
    let output = performMeasuredAction(count: count) {
      for _ in 1...1_000_00 {
        blackHole("")
      }
    }
    
    print("__playground: ", output.duration) // it takes ~22ms for 10 million of calls of empty blackHole(())
    
  } // test func end
}
