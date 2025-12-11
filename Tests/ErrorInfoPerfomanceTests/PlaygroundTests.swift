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
      for index in 1...1_000_00 {
        blackHole(ErrorInfoFuncs.DictUtils.addKeyPrefix("prefix",
                                                        toKeysOf: ["a": 1, "b": 2, "c": 3, "d": 4, "eeeeeeeeeeeeeeeeee": 5]))
      }
    }
    
    print("__playground: ", output.duration)
    
    // 1696.312458
    // __playground:  698.1091240000001
  }
}
