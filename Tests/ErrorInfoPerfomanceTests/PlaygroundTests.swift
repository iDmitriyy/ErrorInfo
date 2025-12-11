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
    let rnd = Int.random(in: 0...1)
    let output = performMeasuredAction(count: count) {
      for index in 1...1_000_000 {
//        blackHole(CollisionTaggedValue<Int, CollisionSource>.value(index))
        blackHole(ErrorInfoFuncs.isEqualEqatableExistential(a: "indexindexindexindex", b: "indexindexindexindex"))
      }
    }
    
    print("__playground: ", output.duration)
    
    // __playground:  595.6978750000001
  }
}
