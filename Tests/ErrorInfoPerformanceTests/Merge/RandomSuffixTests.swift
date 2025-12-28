//
//  RandomSuffixTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 10/12/2025.
//

@_spi(PerformanceTesting) import ErrorInfo
import Testing

struct RandomSuffixTests {
  @Test func basic() {
    var generator = SystemRandomNumberGenerator()
    
    let count = 1000
    let output = performMeasuredAction(count: count) {
      for _ in 1...1000 {
        blackHole(Merge.Utils.randomSuffix(generator: &generator))
      }
    }
    
    print("__randomSuffix: ", output.duration)
    
    // 2484.789388
  }
}
