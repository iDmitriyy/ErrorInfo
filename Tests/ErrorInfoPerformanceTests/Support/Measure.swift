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
  let meanDuration: Duration
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
    meanDuration = averageDuration
    self.measurements = measurements
    self.setupDuration = setupDuration
    self.results = results
  }
}

extension MeasureOutput {
  func measurementsStatSummary() -> StatisticalSummary<Duration> {
    statisticalSummary(of: measurements)
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
///
/// ### Rule of thumb
/// Use case  Best statistic
/// - Very noisy / few samples  **Median**
/// - Moderate noise / want sensitivity  **Trimmed mean**
/// - Low noise / many samples  **Mean**
///
/// ### For performance tests:
/// - Median – safest default
/// - Trimmed mean (10–25%) – best balance
///
/// ### When trimmed mean becomes unreliable
/// 1. Too few samples
/// Minimum recommended samples
/// Median: ≥ 5
/// Trimmed mean (20%): ≥ 10
///
/// 2. Bimodal distributions
/// Example: [1.0, 1.0, 1.0, 1.4, 1.4, 1.4]
/// Trimmed mean: ≈ 1.2  ❌ value that never actually occurs
/// Median: 1.2 (even count) — also misleading
///
/// But the shape tells that the system has two regimes (e.g. core migration, cache state).
/// – Trimmed mean hides this; median hides it too
/// – You must inspect variance or clusters
@inlinable
@inline(__always)
@discardableResult
internal func performMeasuredAction<P, T>(iterations: Int,
                                          setup: (Int) -> P,
                                          measure actions: (inout P) -> T) -> MeasureOutput<T> {
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
  
  let medianDuration = median(of: executionDurations)
  
  return MeasureOutput(totalDuration: totalDuration,
                       medianDuration: medianDuration,
                       averageDuration: totalDuration / iterations,
                       measurements: executionDurations,
                       setupDuration: totalSetupDuration,
                       results: results)
}

@usableFromInline
func median<D: DurationProtocol>(of values: [D]) -> D {
  guard !values.isEmpty else { return .zero }
  
  let sorted = values.sorted()
  let mid = sorted.count / 2
  
  return if sorted.count % 2 == 0 {
    (sorted[mid - 1] + sorted[mid]) / 2
  } else {
    sorted[mid]
  }
}

func median<N: FloatingPoint>(of values: [N]) -> N {
  guard !values.isEmpty else { return .zero }
  
  let sorted = values.sorted()
  let mid = sorted.count / 2
  
  return if sorted.count % 2 == 0 {
    (sorted[mid - 1] + sorted[mid]) / 2
  } else {
    sorted[mid]
  }
}

func mean<N: FloatingPoint>(of values: [N]) -> N {
  guard !values.isEmpty else { return .zero }
  
  let sum = values.reduce(into: N.zero, +=)
  let mean = sum / N(values.count)
  return mean
}

func mean<D: DurationProtocol>(of values: [D]) -> D {
  guard !values.isEmpty else { return .zero }
  
  let sum = values.reduce(into: D.zero, +=)
  let mean = sum / values.count
  return mean
}

/// A structure that contains various statistical measures derived from a collection of values.
struct StatisticalSummary<N> {
  let minValue: N
  
  let maxValue: N
  
  /// The mean (average) of the values in the dataset.
  ///
  /// The mean represents the central value of the dataset. It's calculated by summing all values and dividing by the number of values.
  /// Example:
  /// - If the dataset is `[1, 4, 7]`, the mean is `(1 + 4 + 7) / 3 = 4`.
  /// - If the dataset is `[10.79, 10.83, 10.93]`, the mean is `(10.79 + 10.83 + 10.93) / 3 ≈ 10.85`.
  let mean: N
  
  let median: N
    
  /// The difference between the mean and the minimum value in the dataset.
  ///
  /// This value indicates how far the minimum value is from the mean. A larger value suggests the minimum value is farther from the mean.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the below average delta is `4 - 1 = 3`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a mean of `10.85`, the below average delta is `10.85 - 10.79 = 0.06`.
  let belowMeanDelta: N
  
  /// The difference between the mean and the maximum value in the dataset.
  ///
  /// This value shows how far the maximum value is from the mean. A larger value indicates the maximum value is farther from the mean.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the above average delta is `7 - 4 = 3`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a mean of `10.85`, the above average delta is `10.93 - 10.85 = 0.08`.
  let aboveMeanDelta: N
  
  /// The smallest absolute deviation of any value from the mean.
  ///
  /// This value shows how close the closest value is to the mean. It can be used to understand how tightly the data is clustered around the mean.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the minimum deviation is `abs(4 - 4) = 0`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a mean of `10.85`, the minimum deviation is `abs(10.83 - 10.85) = 0.02`.
  let minAbsDeviation: N
  
  /// The largest absolute deviation of any value from the mean.
  ///
  /// This value represents the greatest distance from the mean. It helps to understand the spread of the data.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the maximum deviation is `max(abs(1 - 4), abs(7 - 4)) = 3`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a mean of `10.85`, the maximum deviation is `0.08`.
  let maxAbsDeviation: N
    
  /// The mean (average) of the absolute deviations from the mean.
  ///
  /// This value shows the average amount by which the values deviate from the mean. It provides a sense of the overall spread of the dataset.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the mean deviation is `(abs(1 - 4) + abs(4 - 4) + abs(7 - 4)) / 3 = 2`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a mean of `10.85`, the mean deviation is
  ///   `(abs(10.79 - 10.85) + abs(10.83 - 10.85) + abs(10.93 - 10.85)) / 3 ≈ 0.0533`.
  let meanAbsoluteDeviation: N
  
  /// The variance of the dataset, which is the average of the squared deviations from the mean.
  ///
  /// Variance measures the overall spread of the data, giving more weight to values that are farther from the mean.
  /// Example: If the dataset is [2, 4, 6] and the mean is 4, the variance is ((2 - 4)^2 + (4 - 4)^2 + (6 - 4)^2) / 3 = 2.67.
  
  /// The variance of the dataset, which is the average of the squared deviations from the mean.
  ///
  /// Variance measures the overall spread of the data, giving more weight to values that are farther from the mean.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a mean of `4`, the variance is `((1 - 4)^2 + (4 - 4)^2 + (7 - 4)^2) / 3 = 6`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a mean of `10.85`, the variance is
  /// `((10.79 - 10.85)^2 + (10.83 - 10.85)^2 + (10.93 - 10.85)^2) / 3 ≈ 0.00346`.
  let variance: N
    
  /// The standard deviation of the dataset, which is the square root of the variance.
  ///
  /// Standard deviation provides a measure of the spread of the dataset, with the same units as the original data. It tells you how much values tend to deviate from the mean.
  /// Example:
  /// - For the dataset `[1, 4, 7]` with a variance of `6`, the standard deviation is `sqrt(6) ≈ 2.45`.
  /// - For the dataset `[10.79, 10.83, 10.93]` with a variance of `≈ 0.00346`, the standard deviation is `sqrt(variance) ≈ 0.05887`.
  let standardDeviation: N
  
  /// The Coefficient of Variation (CV), which is the standard deviation expressed as a percentage of the mean.
  let coefficientOfVariation: Double
}

func statisticalSummary<N: BinaryFloatingPoint>(of values: [[N]]) -> [StatisticalSummary<N>] {
  guard !values.isEmpty else { return [] }
  return values.map(statisticalSummary(of:))
}

func statisticalSummary<N: BinaryFloatingPoint>(of values: [N]) -> StatisticalSummary<N> {
  guard !values.isEmpty else { return .zero }
  
  let sum = values.reduce(into: N.zero, +=)
  let mean = sum / N(values.count)
  
  let median = median(of: values)
  
  let minValue = values.min()!
  let maxValue = values.max()!
  
  let belowMeanDelta: N = mean - minValue
  let aboveMeanDelta: N = maxValue - mean
  
  // Calculate absolute deviations for each value from the mean
  let absDeltasToMean = values.map { abs($0 - mean) }
  
  // Find the minimum absolute deviation
  let minAbsDeviation = absDeltasToMean.min()!
  
  // Find the maximum absolute deviation
  let maxAbsDeviation = absDeltasToMean.max()!
  
  // Calculate the average (mean) of the deviations
  let meanAbsDeviation = absDeltasToMean.reduce(into: N.zero, +=) / N(values.count)
    
  // Calculate squared deviations from the mean
  let squaredDeviations = values.map { ($0 - mean) * ($0 - mean) }
  
  // Calculate variance (average of squared deviations)
  let variance = squaredDeviations.reduce(into: N.zero, +=) / N(values.count)
  
  // Standard deviation is the square root of the variance
  let standardDeviation = variance.squareRoot()
  
  let coefficientOfVariation = standardDeviation / mean
  
  return StatisticalSummary(minValue: minValue,
                            maxValue: maxValue,
                            mean: mean,
                            median: median,
                            belowMeanDelta: belowMeanDelta,
                            aboveMeanDelta: aboveMeanDelta,
                            minAbsDeviation: minAbsDeviation,
                            maxAbsDeviation: maxAbsDeviation,
                            meanAbsoluteDeviation: meanAbsDeviation,
                            variance: variance,
                            standardDeviation: standardDeviation,
                            coefficientOfVariation: Double(coefficientOfVariation))
}

/// copy-paste of FloatingPoint imp
func statisticalSummary(of values: [Duration]) -> StatisticalSummary<Duration> {
  guard !values.isEmpty else { return .zero }
  typealias N = Duration
  
  let sum = values.reduce(into: N.zero, +=)
  let mean = sum / values.count
  
  let median = median(of: values)
  
  let minValue = values.min()!
  let maxValue = values.max()!
  
  let belowMeanDelta: N = mean - minValue
  let aboveMeanDelta: N = maxValue - mean
  
  // Calculate absolute deviations for each value from the mean
  let absDeltasToMean = values.map { abs($0 - mean) }
  
  // Find the minimum absolute deviation
  let minAbsDeviation = absDeltasToMean.min()!
  
  // Find the maximum absolute deviation
  let maxAbsDeviation = absDeltasToMean.max()!
  
  // Calculate the average (mean) of the deviations
  let meanAbsDeviation = absDeltasToMean.reduce(into: N.zero, +=) / values.count
    
  // Calculate squared deviations from the mean
  let squaredDeviations = values.map { squareDuration($0 - mean) }
  
  // Calculate variance (average of squared deviations)
  let variance = squaredDeviations.reduce(into: N.zero, +=) / values.count
  
  // Standard deviation is the square root of the variance
  let standardDeviation = squareRootOfDuration(variance)
  
  let coefficientOfVariation = standardDeviation / mean
  
  return StatisticalSummary(minValue: minValue,
                            maxValue: maxValue,
                            mean: mean,
                            median: median,
                            belowMeanDelta: belowMeanDelta,
                            aboveMeanDelta: aboveMeanDelta,
                            minAbsDeviation: minAbsDeviation,
                            maxAbsDeviation: maxAbsDeviation,
                            meanAbsoluteDeviation: meanAbsDeviation,
                            variance: variance,
                            standardDeviation: standardDeviation,
                            coefficientOfVariation: coefficientOfVariation)
}

extension StatisticalSummary where N: FloatingPoint {
  static var zero: Self {
    Self(minValue: .zero,
         maxValue: .zero,
         mean: .zero,
         median: .zero,
         belowMeanDelta: .zero,
         aboveMeanDelta: .zero,
         minAbsDeviation: .zero,
         maxAbsDeviation: .zero,
         meanAbsoluteDeviation: .zero,
         variance: .zero,
         standardDeviation: .zero,
         coefficientOfVariation: .zero)
  }
}

extension StatisticalSummary where N: DurationProtocol {
  static var zero: Self {
    Self(minValue: .zero,
         maxValue: .zero,
         mean: .zero,
         median: .zero,
         belowMeanDelta: .zero,
         aboveMeanDelta: .zero,
         minAbsDeviation: .zero,
         maxAbsDeviation: .zero,
         meanAbsoluteDeviation: .zero,
         variance: .zero,
         standardDeviation: .zero,
         coefficientOfVariation: .zero)
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

internal func squareRootOfDuration(_ duration: Duration) -> Duration {
  // Handle absolute value of the duration (ignoring negative duration)
  precondition(duration >= .zero, "squareRoot can not be get from negative value")
    
  let attoScaleSqrt: Double = 1_000_000_000
  
  let sqrt = Double(duration.attoseconds).squareRoot()
  let adjustedSqrt = sqrt * attoScaleSqrt
  
  return Duration(attoseconds: Int128(adjustedSqrt))
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

/// Descr
///
/// - Median protects against noise.
/// - Trimmed mean detects drift.
/// - Max guards against spikes.
///
/// ### How to interpret failures
/// |                          Failure                       |         Meaning               |
/// |:-----------------------------------------:|:--------------------------:|
/// | Median fails                                       | Clear regression           |
/// | Trimmed mean fails, median passes | Slow drift                      |
/// | Worst-case fails only                         | Sporadic system issue |
/// | All fail                                                 | Serious regression        |
///
/// This gives you diagnostic power, not just pass/fail.
///
/// ### Practical defaults
/// |           Parameter         |            Value            |
/// |:-------------------------:|:----------------------:|
/// | Runs                            | 7–11                        |
/// | Trim fraction                | 0.15–0.25                 |
/// | Median tolerance        | adaptive                   |
/// | Worst-case allowance | `2×tolerance`   |
func assertPerformanceStable(ratios: [Double],
                             expectedRatio: Double,
                             tolerance: Double) -> Bool {
  precondition(ratios.count >= 7)

  let med = median(of: ratios)
//  let tmean = trimmedMean(ratios, trimFraction: 0.2)
  let tmean = mean(of: trimmedMeasurements(ratios, trimFraction: 0.2))
  let worst = ratios.max()!

  let medianOK = abs(med - expectedRatio) <= tolerance

  let trimmedMeanOK = abs(tmean - expectedRatio) <= tolerance

  let worstCaseOK = worst <= expectedRatio + tolerance * 2

  return medianOK && trimmedMeanOK && worstCaseOK
}

///
///
/// ### How to interpret failures:
/// |                               Signal                              |                 Meaning                  |
/// |:-------------------------------------------------:|:----------------------------------:|
/// | `median OK`, `trimmed mean FAIL` | Systematic regression             |
/// | `percentile FAIL` only                        | Rare spikes (environment)        |
/// | `bimodal = true`                                  | Core migration / cache regime |
/// | Everything fails                                             | Real regression                         |
///
/// ### Recommended defaults (battle-tested)
/// |        Parameter          |                         Value                     |
/// |:-----------------------:|:--------------------------------------:|
/// | Runs                          | 7–11                                             |
/// | Trim fraction              | 0.2                                                |
/// | Percentile                  | 95%                                              |
/// | Gap factor                 | 4×                                                  |
/// | Percentile allowance | `expected + 2×tolerance` |
///
/// # Example:
/// ```
/// let result = evaluatePerformance(ratios: ratios,
///                                  expectedRatio: expectedRatio,
///                                  tolerance: tolerance)
///
/// if !result.passed {
///   XCTFail(result.diagnostics, file: file, line: line)
/// }
/// ```
func evaluatePerformance(ratios: [Double],
                         expectedRatio: Double,
                         tolerance: Double) -> (passed: Bool, diagnostics: String) {

  precondition(ratios.count >= 7)

  let med = median(of: ratios)
  //  let tmean = trimmedMean(ratios, trimFraction: 0.2)
  let tmean = mean(of: trimmedMeasurements(ratios, trimFraction: 0.2))
  let p95 = percentile(ratios, p: 0.95)
  let bimodal = isLikelyBimodal(ratios)

  let medianOK = abs(med - expectedRatio) <= tolerance
  let trimmedOK = abs(tmean - expectedRatio) <= tolerance
  let percentileOK = p95 <= expectedRatio + tolerance * 2

  let passed = medianOK && trimmedOK && percentileOK && !bimodal

  let diagnostics = """
  Performance evaluation failed:
    expected ratio: \(expectedRatio)
    tolerance: ±\(tolerance)
  
    median: \(med)
    trimmed mean: \(tmean)
    95th percentile: \(p95)
  
    median OK: \(medianOK)
    trimmed mean OK: \(trimmedOK)
    percentile OK: \(percentileOK)
    bimodal distribution: \(bimodal)
  
    raw ratios: \(ratios.sorted())
  """

  return (passed, diagnostics)
}

enum PerformanceFailureKind: String {
  /// sustained slowdown
  case regression
  /// scheduling / cache regimes | core migration, cache state, OS noise
  ///
  /// You are saying:
  /// The observed performance difference is dominated by factors outside the code under test.
  /// In other words:
  /// the code behaves consistently within each regime
  /// but the runtime environment switches between regimes
  case environment
  /// statistical instability | insufficient samples / unstable setup
  case noise
}

func classifyFailure(medianOK: Bool,
                     trimmedMeanOK: Bool,
                     percentileOK: Bool,
                     bimodal: Bool) -> PerformanceFailureKind {

  if bimodal {
    return .environment
  }

  if !medianOK, !trimmedMeanOK {
    return .regression
  }

  if medianOK, !trimmedMeanOK {
    return .regression // slow drift
  }

  if !percentileOK {
    return .environment
  }

  return .noise
}

func evaluatePerformance(ratios: [Double],
                         expectedRatio: Double,
                         tolerance: Double,
                         profile: PerformanceTestProfile)
  -> (passed: Bool, label: PerformanceFailureKind?, diagnostics: String) {

  guard ratios.count >= profile.minSamples else {
    return (false, .noise, "insufficient samples: \(ratios.count)")
  }

  let med = median(of: ratios)
//  let tmean = trimmedMean(ratios, trimFraction: profile.trimFraction)
  let tmean = mean(of: trimmedMeasurements(ratios, trimFraction: 0.2))
  let perc = percentile(ratios, p: profile.percentile)
  let bimodal = isLikelyBimodal(ratios, gapFactor: profile.gapFactor)

  let medianOK = abs(med - expectedRatio) <= tolerance
  let trimmedOK = abs(tmean - expectedRatio) <= tolerance
  let percentileOK =
    perc <= expectedRatio + tolerance * profile.percentileMultiplier

  let passed = medianOK && trimmedOK && percentileOK && !bimodal

  let label = passed ? nil :
    classifyFailure(
      medianOK: medianOK,
      trimmedMeanOK: trimmedOK,
      percentileOK: percentileOK,
      bimodal: bimodal,
    )

  let diagnostics = """
  Performance evaluation (\(label?.rawValue ?? "passed")):
  
    expected ratio: \(expectedRatio)
    tolerance: ±\(tolerance)
  
    median: \(med)            [\(medianOK)]
    trimmed mean: \(tmean)    [\(trimmedOK)]
    p\(Int(profile.percentile * 100)): \(perc)       [\(percentileOK)]
    bimodal: \(bimodal)
  
    ratios: \(ratios.sorted())
  
  \(bimodal ? describeRegimes(ratios) : "")
  """

  return (passed, label, diagnostics)
}

/// ```
/// let isCI = ProcessInfo.processInfo.environment["CI"] == nil
/// let profile: PerformanceProfile = isCI ? .localDefault : .ciDefault
/// ```
struct PerformanceTestProfile {
  let trimFraction: Double
  let percentile: Double
  let percentileMultiplier: Double
  let gapFactor: Double
  let minSamples: Int
  
  static let localDefault = Self(trimFraction: 0.20,
                                 percentile: 0.95,
                                 percentileMultiplier: 1.8,
                                 gapFactor: 4.0,
                                 minSamples: 7)

  static let ciDefault = Self(trimFraction: 0.25,
                              percentile: 0.90,
                              percentileMultiplier: 2.5,
                              gapFactor: 6.0,
                              minSamples: 9)
}

func isLikelyBimodal(_ values: [Double], gapFactor: Double = 4.0) -> Bool {
  precondition(values.count >= 6)

  let sorted = values.sorted()
  let gaps = zip(sorted, sorted.dropFirst()).map { $1 - $0 }

  let medianGap = gaps.sorted()[gaps.count / 2]
  let maxGap = gaps.max()!

  return medianGap > 0 && maxGap > gapFactor * medianGap
}

func describeRegimes(_ values: [Double]) -> String {
  let sorted = values.sorted()
  let gaps = zip(sorted, sorted.dropFirst()).map { $1 - $0 }

  // FIXME: - ?? abs
  guard let maxGap = gaps.max(),
        let splitIndex = gaps.firstIndex(of: maxGap) else {
    return "single regime"
  }

  let left = Array(sorted.prefix(splitIndex + 1))
  let right = Array(sorted.suffix(from: splitIndex + 1))

  func summary(_ v: [Double]) -> String {
    let min = v.first!
    let max = v.last!
    let med = median(of: v)
    return String(format: "count=%d min=%.3f med=%.3f max=%.3f",
                  v.count, min, med, max)
  }

  return """
  bimodal distribution detected:
    regime A: \(summary(left))
    regime B: \(summary(right))
    separation gap: \(String(format: "%.3f", maxGap))
  """
}

/// Percentile-based guard (instead of max)
///
/// If using max is too sensitive.
///
/// Typical choice:
/// - p = 0.95 → CI-safe
/// - p = 0.90 → stricter
func percentile(_ values: [Double], p: Double) -> Double {
  precondition(0...1 ~= p)
  let sorted = values.sorted()
  let index = Int(Double(sorted.count - 1) * p)
  return sorted[index]
}

/// possible fix is median-of-ratios (or trimmed mean) across multiple runs, not larger tolerance.
///
/// ## Median vs trimmed mean (what each optimizes)
/// ### Median
/// - Uses one data point (or two)
/// - Completely ignores magnitude of other values
/// - Extremely robust to outliers
/// - Higher variance (less sensitive)
///
/// ### Trimmed mean
/// - Uses many central points
/// - Discards only extreme tails
/// - More efficient estimator (lower variance)
/// - Still robust to outliers
///
/// So trimmed mean sits between mean and median.
///
/// ### Also:
/// - Median hides the skew
/// - Trimmed mean reveals it
///
/// ### Trimmed mean gives:
/// - Much of mean’s sensitivity
/// - Much of median’s robustness
func trimmedMeasurements<T: Comparable>(_ values: [T], trimFraction: Double = 0.2) -> [T] {
  precondition(trimFraction >= 0 && trimFraction <= 0.5)
  
  let sorted = values.sorted()
  let trimCount = Int(Double(sorted.count) * trimFraction)
  let trimmed = sorted.dropFirst(trimCount).dropLast(trimCount)
  return Array(trimmed)
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

func tempFileURL(fileName: String) -> URL {
  let tempDir = FileManager.default.temporaryDirectory
  let fileName = "test_\(fileName).txt"
  return tempDir.appendingPathComponent(fileName)
}

func appendDouble(_ value: Double, toFile fileURL: URL) throws {
  let stringValue = "\(value)\n"
  let data = Data(stringValue.utf8)
  let fileManager = FileManager.default

  if fileManager.fileExists(atPath: fileURL.path) {
    // Append to existing file
    let fileHandle = try FileHandle(forWritingTo: fileURL)
    defer { fileHandle.closeFile() }
    try fileHandle.seekToEnd()
    fileHandle.write(data)
    print("=== fileHandle.write(data) \(fileURL)")
  } else {
    // Create new file
    try data.write(to: fileURL, options: .atomic)
    print("=== data.write(to: \(fileURL)")
  }
}

/// Reads all double values from a file, returns them as [Double].
/// Throws an error if any line cannot be converted to Double.
func readDoubles(from fileURL: URL) throws -> [Double] {
  let content = try String(contentsOf: fileURL, encoding: .utf8)
  let lines = content.split(separator: "\n")
    
  return try lines.map { line in
    guard let value = Double(line) else { throw ReadDoubleError.invalidLine(String(line)) }
    return value
  }
}

func throwError() throws {
  throw ReadDoubleError.invalidLine("dwfdsfsdf")
}

fileprivate enum ReadDoubleError: Error, LocalizedError {
  case invalidLine(String)
  var errorDescription: String? {
    switch self {
    case .invalidLine(let line): "Cannot convert '\(line)' to Double."
    }
  }
}

func removeFileIfExists(at fileURL: URL) throws {
  let fileManager = FileManager.default
  if fileManager.fileExists(atPath: fileURL.path) {
    try fileManager.removeItem(at: fileURL)
  }
}
