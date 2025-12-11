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
//        blackHole(CollisionTaggedValue<Int, CollisionSource>.value(index))
        blackHole(StringLiteralKey.request + .id)
      }
    }
    
    print("__playground: ", output.duration)
    
    // __playground:  108.76071
  }
}
