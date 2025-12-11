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
        let ind = "\(index)"
        // String.concat()
//        blackHole("pref" + "(" + ind + " :)" + ind + "suffix")
//        blackHole(["pref", "(" , ind , " :)", "suffix"].joined())
      }
    }
    
    print("__playground: ", output.duration)
    
    // __playground:  438.804459 vs concat_3 (456.75612400000006)
    
    // 1173.270501 concat_4  | 982 +
    // 1419 | 1724.66329 +
    // 1588 | 1823
    // 1398 | 1665 join
  }
}
