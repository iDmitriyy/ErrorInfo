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
      for index in 1...1000000 {
        blackHole(CollisionTaggedValue<Int, CollisionSource>.value(index))
//        blackHole(CollisionTaggedValue<Int, CollisionSource>(value: index, collisionSource: .onCreateWithDictionaryLiteral))
      }
    }
    
    print("__playground: ", output.duration)
    
    // __playground:  1250.471209 .value
    // __playground:  1951.508291 .collidedValue
    
    // __playground:  24.3932920000000021250.471209
    // __playground:  320.86487500000004 .collidedValue
  }
}
