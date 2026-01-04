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
  -> (totalDuration: Duration, medianDuration: Duration, setupDuration: Duration, results: [T]) {
  let clock = ContinuousClock()
    
  var results: [T] = []
  results.reserveCapacity(iterations)
  
  var executionDurations: [Duration] = []
  executionDurations.reserveCapacity(iterations)
    
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
    executionDurations.append(executionDuration)
    
    results.append(result)
  }
  
  let medianDuration = median(executionDurations)
  
  return (totalExecutionDuration, medianDuration, totalSetupDuration, results)
}

@inlinable
@inline(__always)
func median(_ values: [Duration]) -> Duration {
  guard !values.isEmpty else { return .zero }
  
  let sorted = values.sorted()
  let mid = sorted.count / 2
  
  return if sorted.count % 2 == 0 {
    (sorted[mid - 1] + sorted[mid]) / 2
  } else {
    sorted[mid]
  }
}

@inlinable
@inline(__always)
func averageWithDelta<F: FloatingPoint>(_ values: [[F]])
  -> [(average: F, lowerDelta: F, upperDelta: F, minDelta: F, maxDelta: F, averageDelta: F)] {
  guard !values.isEmpty else { return [] }
  return values.map(averageWithDelta(_:))
}

@inlinable
@inline(__always)
func averageWithDelta<F: FloatingPoint>(_ values: [F])
  -> (average: F, lowerDelta: F, upperDelta: F, minDelta: F, maxDelta: F, averageDelta: F) {
  guard !values.isEmpty else { return (.zero, .zero, .zero, .zero, .zero, .zero) }
  
  let sum = values.reduce(into: F.zero) { result, value in result += value }
  
  let average = sum / F(values.count)
  
  let minValue = values.min()!
  let maxValue = values.max()!
  
  let lowerDelta: F = average - minValue
  let upperDelta: F = maxValue - average
  
  let maxDelta: F = F.maximum(lowerDelta, upperDelta)
  
  let deltasToAverage = values.map { abs($0 - average) }
  let minDelta = deltasToAverage.min()!
  
  let averageDelta = deltasToAverage.reduce(into: F.zero) { result, value in result += value } / F(values.count)
  
  return (average, lowerDelta, upperDelta, minDelta, maxDelta, averageDelta)
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

//@inlinable @inline(__always)
func adaptiveRatioTolerance(iterations: Int,
                            baseTolerance: Double = 0.15,
                            minimumTolerance: Double = 0.005) -> Double {
  precondition(iterations > 0)
  return max(baseTolerance / sqrt(Double(iterations)), minimumTolerance)
}

/// Returns a ratio tolerance that adapts to the number of iterations used in a
/// performance measurement.
///
/// The returned tolerance decreases proportionally to `1 / √iterations`,
/// reflecting the fact that measurement noise diminishes as more iterations
/// are performed.
///
/// This function is intended for stabilizing performance tests whose absolute
/// timings vary between runs, machines, or environments.
///
/// ### Formula
/// ```text
/// tolerance = baseTolerance × √(referenceIterations / iterations)
/// ```
///
/// The result is clamped to `minimumTolerance` to avoid unrealistically strict
/// comparisons.
///
/// ### Example
/// ```swift
/// let tolerance = adaptiveRatioTolerance(iterations: 1_000)
/// // ≈ 0.016 (±1.6%)
/// ```
///
/// ### Default values behavior
///
/// | Iterations | Computed tolerance |
/// |:-----------:|:-------------------:|
/// | 10            | ±15.8%               |
/// | 100          | ±5.0%                 |
/// | 1 000       | ±1.6%                 |
/// | 10 000     | ±0.5%                 |
///
/// - Parameters:
///   - iterations: The number of iterations used in the measurement.
///   - baseTolerance: The expected relative tolerance at `referenceIterations`.
///     Defaults to `0.05` (±5%).
///   - referenceIterations: The iteration count at which `baseTolerance` is
///     considered normal. Defaults to `100`.
///   - minimumTolerance: The lower bound for the returned tolerance.
///     Defaults to `0.005` (±0.5%).
/// - Returns: A relative tolerance suitable for comparing duration ratios.
@inline(__always)
func adaptiveRatioTolerance(
  iterations: Int,
  baseTolerance: Double = 0.05,
  referenceIterations: Int = 100,
  minimumTolerance: Double = 0.005
) -> Double {
  precondition(iterations > 0)
  precondition(referenceIterations > 0)

  let scaled = baseTolerance * sqrt(Double(referenceIterations) / Double(iterations))
  return max(scaled, minimumTolerance)
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
