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

@usableFromInline struct MeasureOutput<T> {
  let totalDuration: Duration
  let medianDuration: Duration
  let averageDuration: Duration
  let measurements: [Duration]
  let setupDuration: Duration
  let results: [T]
  
  @usableFromInline
  init(totalDuration: Duration,
       medianDuration: Duration,
       averageDuration: Duration,
       measurements: [Duration],
       setupDuration: Duration,
       results: [T]) {
    self.totalDuration = totalDuration
    self.medianDuration = medianDuration
    self.averageDuration = averageDuration
    self.measurements = measurements
    self.setupDuration = setupDuration
    self.results = results
  }
}

/// One iteration should take at least 50× the clock’s minimum resolution.
/// Om M1 processors, Clock.minimumResolution == 0.042 µs.
///
/// ### Recommendations:
/// - Tolerance handles noise.
/// - Medians handle outliers.
///
/// ### When spikes mean something is wrong
/// Spikes are a bug if:
/// - they happen frequently (>20% of runs)
/// - both baseline and measured spike together
/// - variance grows with iteration count
///
/// | Target per-iteration time |                     Quality                          |
/// |:---------------------------:|------------------------------------------|
/// |                       < 5 µs | ❌ unreliable            |
/// |                        10–20 µs | ⚠️ barely usable                                |
/// |                      50–200 µs | ✅ good                                             |
/// |                        0.5–2 ms | ✅ excellent                                       |
/// |                         > 10 ms | ❌ too slow for iteration-based tests |
@inlinable
@inline(__always)
@discardableResult
internal func performMeasuredAction<P, T>(iterations: Int,
                                          setup: (Int) -> P,
                                          measure actions: (inout P) -> T)
  -> MeasureOutput<T> {
  let clock = ContinuousClock()
    
  var results: [T] = []
  results.reserveCapacity(iterations)
  
  var executionDurations: [Duration] = []
  executionDurations.reserveCapacity(iterations)
    
  var totalSetupDuration = Duration.zero
  var totalDuration = Duration.zero
    
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
    totalDuration += executionDuration
    executionDurations.append(executionDuration)
    
    results.append(result)
  }
  
  let medianDuration = median(executionDurations)
  
  return MeasureOutput(totalDuration: totalDuration,
                       medianDuration: medianDuration,
                       averageDuration: totalDuration / iterations,
                       measurements: executionDurations,
                       setupDuration: totalSetupDuration,
                       results: results)
}

@usableFromInline
func median<D: DurationProtocol>(_ values: [D]) -> D {
  guard !values.isEmpty else { return .zero }
  
  let sorted = values.sorted()
  let mid = sorted.count / 2
  
  return if sorted.count % 2 == 0 {
    (sorted[mid - 1] + sorted[mid]) / 2
  } else {
    sorted[mid]
  }
}

func median<N: FloatingPoint>(_ values: [N]) -> N {
  guard !values.isEmpty else { return .zero }
  
  let sorted = values.sorted()
  let mid = sorted.count / 2
  
  return if sorted.count % 2 == 0 {
    (sorted[mid - 1] + sorted[mid]) / 2
  } else {
    sorted[mid]
  }
}

/// possible fix is median-of-ratios (or trimmed mean) across multiple runs, not larger tolerance.
func trimmedMeasurements<T: Comparable>(_ values: [T], trimFraction: Double = 0.2) -> [T] {
  precondition(trimFraction >= 0 && trimFraction <= 0.5)
  
  let sorted = values.sorted()
  let trimCount = Int(Double(sorted.count) * trimFraction)
  let trimmed = sorted.dropFirst(trimCount).dropLast(trimCount)
  return Array(trimmed)
}

/// A structure that contains various statistical measures derived from a collection of values.
struct AverageWithDelta<N> {
  /// The mean (average) of the values in the dataset.
  ///
  /// The mean represents the central value of the dataset. It's calculated by summing all values and dividing by the number of values.
  /// Example:
  /// - If the dataset is `[1, 4, 7]`, the mean is `(1 + 4 + 7) / 3 = 4`.
  /// - If the dataset is `[10.79, 10.83, 10.93]`, the mean is `(10.79 + 10.83 + 10.93) / 3 ≈ 10.85`.
  let mean: N
    
  /// The difference between the mean and the minimum value in the dataset.
  ///
  /// This value indicates how far the minimum value is from the mean. A larger value suggests the minimum value is farther from the mean.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the below average delta is `4 - 1 = 3`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a mean of `10.85`, the below average delta is `10.85 - 10.79 = 0.06`.
  let belowAverageDelta: N
  
  /// The difference between the mean and the maximum value in the dataset.
  ///
  /// This value shows how far the maximum value is from the mean. A larger value indicates the maximum value is farther from the mean.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the above average delta is `7 - 4 = 3`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a mean of `10.85`, the above average delta is `10.93 - 10.85 = 0.08`.
  let aboveAverageDelta: N
    
  /// The smallest absolute deviation of any value from the mean.
  ///
  /// This value shows how close the closest value is to the mean. It can be used to understand how tightly the data is clustered around the mean.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the minimum deviation is `abs(4 - 4) = 0`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a mean of `10.85`, the minimum deviation is `abs(10.83 - 10.85) = 0.02`.
  let minDeviation: N
    
  /// The largest absolute deviation of any value from the mean.
  ///
  /// This value represents the greatest distance from the mean. It helps to understand the spread of the data.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the maximum deviation is `max(abs(1 - 4), abs(7 - 4)) = 3`.
  /// - For the dataset `[0.72, 0.69, 0.75]` with a mean of `0.72`, the maximum deviation is `max(abs(0.72 - 0.72), abs(0.75 - 0.72)) = 0.03`.
  let maxDeviation: N
  
  /// The mean (average) of the absolute deviations from the mean.
  ///
  /// This value shows the average amount by which the values deviate from the mean. It provides a sense of the overall spread of the dataset.
  /// Example: If the dataset is [2, 4, 6] and the mean is 4, the mean deviation is (abs(2 - 4) + abs(4 - 4) + abs(6 - 4)) / 3 = 1.33.
  let meanDeviation: N
  
  /// The variance of the dataset, which is the average of the squared deviations from the mean.
  ///
  /// Variance measures the overall spread of the data, giving more weight to values that are farther from the mean.
  /// Example: If the dataset is [2, 4, 6] and the mean is 4, the variance is ((2 - 4)^2 + (4 - 4)^2 + (6 - 4)^2) / 3 = 2.67.
  let variance: N
  
  /// The standard deviation of the dataset, which is the square root of the variance.
  ///
  /// Standard deviation provides a measure of the spread of the dataset, with the same units as the original data. It tells you how much values tend to deviate from the mean.
  /// Example: If the dataset is [2, 4, 6] and the variance is 2.67, the standard deviation is sqrt(2.67) ≈ 1.63.
  let standardDeviation: N
}

func averageWithDelta<N: FloatingPoint>(_ values: [[N]]) -> [AverageWithDelta<N>] {
  guard !values.isEmpty else { return [] }
  return values.map(averageWithDelta(_:))
}

func averageWithDelta<N: FloatingPoint>(_ values: [N]) -> AverageWithDelta<N> {
  guard !values.isEmpty else { return .zero }
  
  let sum = values.reduce(into: N.zero, +=)
  let mean = sum / N(values.count)
  
  let minValue = values.min()!
  let maxValue = values.max()!
  
  let belowAverageDelta: N = mean - minValue
  let aboveAverageDelta: N = maxValue - mean
  
  // Find the maximum absolute deviation
  let maxDeviation: N = N.maximum(belowAverageDelta, aboveAverageDelta)
  
  // Calculate absolute deviations for each value from the mean
  let deltasToAverage = values.map { abs($0 - mean) }
  
  // Find the minimum absolute deviation
  let minDeviation = deltasToAverage.min()!
  
  // Calculate the average (mean) of the deviations
  let meanDeviation = deltasToAverage.reduce(into: N.zero, +=) / N(values.count)
  
  // Calculate squared deviations from the mean
  let squaredDeviations = values.map { ($0 - mean) * ($0 - mean) }
  
  // Calculate variance (average of squared deviations)
  let variance = squaredDeviations.reduce(into: N.zero, +=) / N(values.count)
  
  // Standard deviation is the square root of the variance
  let standardDeviation = variance.squareRoot()
  
  return AverageWithDelta(mean: mean,
                          belowAverageDelta: belowAverageDelta,
                          aboveAverageDelta: aboveAverageDelta,
                          minDeviation: minDeviation,
                          maxDeviation: maxDeviation,
                          meanDeviation: meanDeviation,
                          variance: variance,
                          standardDeviation: standardDeviation)
}

/// copy-paste of FloatingPoint imp
//func averageWithDelta<D: DurationProtocol>(_ values: [D]) -> AverageWithDelta<D> {
//  guard !values.isEmpty else { return .zero }
//  
//  let sum = values.reduce(into: D.zero, +=)
//  
//  let average = sum / values.count
//  
//  let minValue = values.min()!
//  let maxValue = values.max()!
//  
//  let belowAverageDelta: D = average - minValue
//  let aboveAverageDelta: D = maxValue - average
//  
//  let maxDeviation: D = max(belowAverageDelta, aboveAverageDelta)
//  
//  let deltasToAverage = values.map { abs($0 - average) }
//  let minDeviation = deltasToAverage.min()!
//  
//  let averageDeviation = deltasToAverage.reduce(into: D.zero, +=) / values.count
//  
//  // Calculate squared deviations from the mean
////  let squaredDeviations = values.map { ($0 - average) * ($0 - average) }
////
////  // Calculate variance (average of squared deviations)
////  let variance = squaredDeviations.reduce(into: D.zero, +=) / values.count
////
////  // Standard deviation is the square root of the variance
////  let standardDeviation = variance.squareRoot()
//  
//  return AverageWithDelta(mean: average,
//                          belowAverageDelta: belowAverageDelta,
//                          aboveAverageDelta: aboveAverageDelta,
//                          minDeviation: minDeviation,
//                          maxDeviation: maxDeviation,
//                          meanDeviation: averageDeviation)
//}

extension AverageWithDelta where N: FloatingPoint {
  static var zero: Self {
    Self(mean: .zero,
         belowAverageDelta: .zero,
         aboveAverageDelta: .zero,
         minDeviation: .zero,
         maxDeviation: .zero,
         meanDeviation: .zero,
         variance: .zero,
         standardDeviation: .zero)
  }
}

extension AverageWithDelta where N: DurationProtocol {
  static var zero: Self {
    Self(mean: .zero,
         belowAverageDelta: .zero,
         aboveAverageDelta: .zero,
         minDeviation: .zero,
         maxDeviation: .zero,
         meanDeviation: .zero,
         variance: .zero,
         standardDeviation: .zero)
  }
}

func abs<N: DurationProtocol>(_ duration: N) -> N {
  duration < .zero ? .zero - duration : duration
}

@available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
internal func squareDuration(_ duration: Duration) -> Duration {
  let duration = abs(duration)
  let attoScale: Int128 = 1_000_000_000_000_000_000
  
  let seconds = duration.attoseconds / attoScale
  let squaredSeconds = seconds * seconds
  
  let a = seconds
  let b = duration.attoseconds % attoScale
  let crossTerm = 2 * a * b
  
  let squaredAttoseconds = b * b
  let squaredAttosecndsAdjusted = squaredAttoseconds / attoScale
  
  let squaredSecondsAdjusted = (squaredSeconds * attoScale)
  return Duration(attoseconds: squaredSecondsAdjusted + crossTerm + squaredAttosecndsAdjusted)
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
/// This states:` When I run 100 iterations, ±5% variation is acceptable.`
///
/// | Iterations | Effective tolerance       |
/// |:---------:|-----------------------------|
/// |         25 | 2× noisier → ±10%         |
/// |        100 | expected noise → ±5% |
/// |        400 | 2× cleaner → ±2.5%      |
/// |      1 600 | 4× cleaner → ±1.25%   |
///
/// ### How to choose referenceIterations
///
/// Pick the iteration count where:
/// - The benchmark usually feels “stable”
/// - You’ve observed acceptable variance
///
/// **Common choices**:
/// |         Context        | Typical value |
/// |:--------------------:|:--------------:|
/// | Heavy workloads  | 20–50           |
/// | Microbenchmarks | 100              |
/// | Tight loops            | 500              |
/// | CI environments   | 200–500       |
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
  minimumTolerance: Double = 0.005,
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
  @usableFromInline internal var inNanoseconds: Double {
    let (seconds, attoseconds) = components
    return Double(seconds) * 1_000_000_000 + Double(attoseconds) * 1e-9
  }
  
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
