//
//  Measure.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

import Foundation

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

@inlinable
@inline(__always)
@discardableResult
internal func performMeasuredAction<T>(count: Int, _ actions: () -> T) -> (results: [T], duration: Double) {
  let clock = ContinuousClock()
    
  var results: [T] = []
  
  var totalDuration = Duration.zero
  for _ in 0..<count {
    let initialTime = clock.now
    let result = actions()
    let endTime = clock.now
    let difference = endTime - initialTime
    totalDuration += difference
    results.append(result)
  }
  
  let ms = totalDuration.inMilliseconds
  
  return (results, ms)
}

@inlinable
@inline(__always)
@discardableResult
internal func performMeasuredAction<P, T>(iterations: Int,
                                          setup: (Int) -> P,
                                          measure actions: (inout P) -> T)
  -> (duration: Duration, setupDuration: Duration, results: [T], ) {
  let clock = ContinuousClock()
    
  var results: [T] = []
  results.reserveCapacity(iterations)
    
  var totalSetupDuration = Duration.zero
  var totalExecutionDuration = Duration.zero
  for index in 0..<iterations {
    let setupStart = clock.now
    var preparedData = setup(index)
    let setupEnd = clock.now
    
    let actionStart = clock.now
    let result = actions(&preparedData)
    let actionEnd = clock.now
    
    let setupDuration = setupEnd - setupStart
    totalSetupDuration += setupDuration
    
    let executionDuration = actionEnd - actionStart
    totalExecutionDuration += executionDuration
    
    results.append(result)
  }
  
  return (totalExecutionDuration, totalSetupDuration, results)
}

// This gives inaccurate results
// @inlinable
// @inline(__always)
// @discardableResult
// internal func performMeasuredAction<P, T>(iterations: Int,
//                                          setup: (Int) -> P,
//                                          measureOverhead: (inout P) -> T,
//                                          measure actions: (inout P) -> T)
//  -> (adjustedDuration: Duration, executionDuration: Duration, setupDuration: Duration, results: [T]) {
//  let clock = ContinuousClock()
//
//  var results: [T] = []
//  var overheadResults: [T] = []
//
//  var totalSetupDuration = Duration.zero
//  var totalOverheadDuration = Duration.zero
//  var totalExecutionDuration = Duration.zero
//  for index in 0..<iterations {
//    let setupStart = clock.now
//    var preparedData = setup(index)
//    let setupEnd = clock.now
//
//    let overheadStart = clock.now
//    let overheadResult = measureOverhead(&preparedData)
//    let overheadEnd = clock.now
//
//    let actionStart = clock.now
//    let result = actions(&preparedData)
//    let actionEnd = clock.now
//
//    totalSetupDuration += (setupEnd - setupStart)
//    totalOverheadDuration += (overheadEnd - overheadStart)
//    totalExecutionDuration += (actionEnd - actionStart)
//
//    results.append(result)
//    overheadResults.append(overheadResult)
//  }
//
//  blackHole(overheadResults)
//  let adjustedExecutionDuration = totalExecutionDuration - totalOverheadDuration
//
//  return (adjustedExecutionDuration, totalExecutionDuration, totalSetupDuration, results)
// }

extension Duration {
  @usableFromInline internal var inMicroseconds: Double {
    let (seconds, attoseconds) = components
    return Double(seconds) * 1_000_000 + Double(attoseconds) * 1e-12
  }
  
  @usableFromInline internal var inMilliseconds: Double {
    let (seconds, attoseconds) = components
    return Double(seconds) * 1000 + Double(attoseconds) * 1e-15
  }
  
  @usableFromInline internal var inSeconds: Double {
    let (seconds, attoseconds) = components
    return Double(seconds) + Double(attoseconds) * 1e-18
  }
}

struct VariadicTuple<each T> {
  let elements: (repeat each T)
  
  init(_ elements: repeat each T) {
    self.elements = (repeat each elements)
  }
}

@inline(never) @_optimize(none)
public func blackHole<T>(_ thing: T) {
  _ = thing
}

@inline(never) @_optimize(none)
public func emptyFunc0() {}

@inline(never) @_optimize(none)
public func emptyFunc1() {}

extension Double {
  public func asString(fractionDigits: UInt8) -> String {
    String(format: "%.\(fractionDigits)f", self)
  }
}

@inlinable @inline(__always)
internal func mutate<T: ~Copyable, E>(value: consuming T, mutation: (inout T) throws(E) -> Void) throws(E) -> T {
  try mutation(&value)
  return value
}
