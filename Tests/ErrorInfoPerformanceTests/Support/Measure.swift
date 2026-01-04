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
  -> (duration: Duration, setupDuration: Duration, results: [T]) {
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

/// Returns a Boolean value indicating whether a duration is approximately
/// equal to a baseline duration multiplied by an expected ratio, within
/// `expectedRatio ± ratioTolerance`.
///
/// This function is for stable, ratio-based comparisons of durations,
/// such as performance tests where absolute timings may vary between runs.
///
/// ### Example
/// ```swift
/// let baseline = Duration.milliseconds(100)
/// let measured = Duration.milliseconds(130)
///
/// isDuration(measured,
///            relativeTo: baseline,
///            expectedRatio: 1.3,
///            ratioTolerance: 0.01)
/// // true
/// ```
///
/// - Parameters:
///   - duration: The measured duration to evaluate.
///   - baselineDuration: The reference duration used as the comparison baseline.
///   - expectedRatio: The expected ratio between `duration` and `baselineDuration`.
///   - ratioTolerance: The allowed deviation from `expectedRatio`.
/// - Returns: `true` if the ratio of `duration` to `baselineDuration` lies within
///   the allowed tolerance; otherwise, `false`.
@inlinable @inline(__always)
func isDuration(_ duration: Duration,
                relativeTo baselineDuration: Duration,
                expectedRatio: Double,
                ratioTolerance: Double) -> Bool {
  precondition(baselineDuration > .zero, "Baseline duration must be non-zero")
  precondition(expectedRatio.isFinite && expectedRatio > 0)
  precondition(ratioTolerance.isFinite && ratioTolerance >= 0)
  precondition(expectedRatio - ratioTolerance > 0)
  
  let measuredRatio = abs(duration / baselineDuration)
  
  let lowerBound = expectedRatio - ratioTolerance
  let upperBound = expectedRatio + ratioTolerance
  
  return lowerBound <= measuredRatio && measuredRatio <= upperBound
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
