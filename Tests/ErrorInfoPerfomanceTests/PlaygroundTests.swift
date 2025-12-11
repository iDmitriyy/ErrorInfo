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
    let values = ValuesForKey<any ErrorInfoValueType>(__array: NonEmptyArray("head", "tail"))
    let output = performMeasuredAction(count: count) {
      for index in 1...1_000_00 {
        for e in values {
          blackHole(e)
        }
      }
    }
    
    print("__playground: ", output.duration)
    
    //
  }
}
