//
//  FindCommonElementsAcross.swift
//  ErrorInfo
//
//  Created by tmp on 04/10/2025.
//

@testable import ErrorInfo
import Testing

struct FindCommonElementsAcross {
  let set0: Set<String> = (0...500).map(String.init(describing:)).apply(Set.init)
  let set1: Set<String> = (450...550).map(String.init(describing:)).apply(Set.init)
  let set2: Set<String> = (450...1000).map(String.init(describing:)).apply(Set.init)
  let set3: Set<String> = (400...500).map(String.init(describing:)).apply(Set.init)
  let set4: Set<String> = (0...550).map(String.init(describing:)).apply(Set.init)
  
  @Test func findCommonElements_() {
    let output = performMeasuredAction(count: 100) {
      findCommonElements(across: [set0, set1, set2, set3, set4])
    }
    
    // 3.657 3.522 3.590
    print(output.duration)
  }
}

@discardableResult
public func performMeasuredAction<T>(count: Int, _ actions: () -> T) -> (results: [T], duration: Double) {
  let clock = ContinuousClock()
  
  var results: [T] = []
  var totalDuration = Duration.zero
  for _ in 1...count{
    let initialTime = clock.now
    let result = actions()
    let endTime = clock.now
    let difference = endTime - initialTime
    totalDuration += difference
    results.append(result)
  }
  
  return (results, totalDuration.inMilliseconds)
}

@discardableResult
public func performMeasuredAction<T>(_ actions: () -> T) -> (result: T, duration: Double) {
  let clock = ContinuousClock()
  
  let initialTime = clock.now
  let result = actions()
  let endTime = clock.now
  let difference = endTime - initialTime
  
  return (result, difference.inMilliseconds)
}

extension Duration {
  var inMilliseconds: Double {
    let v = components
    return Double(v.seconds) * 1000 + Double(v.attoseconds) * 1e-15
  }
}
