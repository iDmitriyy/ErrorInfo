//
//  Measure.swift
//  ErrorInfo
//
//  Created by tmp on 06/10/2025.
//

@inlinable
@inline(__always)
@discardableResult
internal func performMeasuredAction<T>(count: Int, _ actions: () -> T) -> (results: [T], duration: Double) {
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

@inlinable
@inline(__always)
@discardableResult
internal func performMeasuredAction<T>(_ actions: () -> T) -> (result: T, duration: Double) {
  let clock = ContinuousClock()
  
  let initialTime = clock.now
  let result = actions()
  let endTime = clock.now
  let difference = endTime - initialTime
  
  return (result, difference.inMilliseconds)
}

extension Duration {
  @usableFromInline internal var inMilliseconds: Double {
    let (seconds, attoseconds) = components
    return Double(seconds) * 1000 + Double(attoseconds) * 1e-15
  }
}

struct VariadicTuple<each T> {
  let elements: (repeat each T)
  
  init(_ elements: repeat each T) {
    self.elements = (repeat each elements)
  }
}
