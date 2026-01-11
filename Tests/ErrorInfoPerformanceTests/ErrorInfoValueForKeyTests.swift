//
//  ErrorInfoValueForKeyTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 02/01/2026.
//

import ErrorInfo
import Foundation
import NonEmpty
import OrderedCollections
import Synchronization
import Testing

/// Relative performance compared to OrderedDictionary
struct ErrorInfoValueForKeyTests {
  private let measurementsCount: Int = 100 //
  private let factor: Double = 5
  
  private var iterations: Int {
    Int((Double(measurementsCount) * factor).rounded(.toNearestOrAwayFromZero))
  }
  
  private let innerLoopCount: Int = 20000 // 20000 is optimal for one measurement be ~= 450-800 µs
  private var innerLoopRange: Range<Int> { 0..<innerLoopCount }
  
  private static let key = String(describing: StringLiteralKey.id)
  private let key = String(describing: StringLiteralKey.id)
  
  private let printPrefix = "____"
    
  // ===-------------------------------------------------------------------------------------------------------------------=== //

  // MARK: - lastRecordedForKey
  
  @Test(.serialized, arguments: BackingStorageKind.allCases)
  func lastRecordedForKey(storageKind: BackingStorageKind) throws {
    let config = Config(iterations: iterations, innerLoopRange: innerLoopRange, storageKind: storageKind)
    
    var ratios: [Double] = []
    for run in 0...11 {
      let ratio = Self.lastRecordedForKey_Ratio(config: config)
      if run == 0 { continue } // run 0 is preheat
      ratios.append(ratio)
    }
    
    let statSummary = statisticalSummary(of: ratios)
    // print("____ratios:", ratios.map { $0.rounded(toPlaces: 3) })
    // print("____median:", statSummary.median.rounded(toPlaces: 3))
    // printStatSummary(statSummary, named: "ratios", printPrefix: "____===>", fractionDigits: 3)
    let median = statSummary.median
    
    switch storageKind {
    case .singleForKey(let variant):
      switch variant {
      case .noValues:
        // 0.747, 0.747, 0.747, 0.746, 0.746, 0.747, 0.747
        // 0.847, 0.847, 0.847, 0.847, 0.847, 0.847
        #expect(median <= 0.87)
      case .singleValue:
        // 1.066 1.067 1.059 1.061
        // 1.180 1.191 1.183 1.185 1.184 1.186 1.178 1.185
        #expect(median <= 1.21)
      }
    case .multiForKey(let variant):
      switch variant {
      case .noValues:
        // 1.454 1.455 1.451
        // 1.650 1.648 1.766 1.652 1.762 1.653
        #expect(median <= 1.78)
      case .singleValue:
        // iterations: 1000
        // 2.870   | abs deviation max: 0.010
        // 3.181 3.104 3.103 3.121 3.100 | abs deviation max: 0.008 0.007 0.007 0.008 0.002
        // iterations: 100
        // 3.107 3.100 3.110 3.100 | abs deviation max: 0.118 0.090 0.076 0.074
        // 3.27 3.274 3.273 3.265 3.267
        #expect(median <= 3.295)
      case .twoValues(let nilPosition):
        switch nilPosition {
        case .withoutNil:
          // 3.181
          // 3.467 3.570 3.462 3.478 3.489 3.583 3.487
          #expect(median <= 3.6)
        case .atStart:
          // 3.224 3.101 3.099
          // 3.466 3.468 3.592 3.548 3.494 3.558
          #expect(median <= 3.66)
        case .atEnd:
          // 2.761 2.866 2.752
          // 3.072 3.077 3.098
          // 3.209 3.184 3.197
          #expect(median <= 3.25)
        }
      }
    }
  }
  
  @inline(never)
  static func lastRecordedForKey_Ratio(config: Config) -> Double {
    let overhead = overheadMeasureOutput(config: config)
    
    let measured = performMeasuredAction(iterations: config.iterations, setup: { index in
      Self.makeIDKeyInstance(storageKind: config.storageKind, index: index)
    }, measure: { info in
      for _ in config.innerLoopRange {
        blackHole(info.lastRecorded(forKey: key))
      }
    })
    
    let baseline = baselineMeasureOutput(config: config)
    
    let adjustedMeasuredDuration = measured.medianDuration - overhead.medianDuration
    let adjustedBaselineDuration = baseline.medianDuration - overhead.medianDuration
    
//    printStat(for: measured, named: "measured", printPrefix: "____===>")
//    printStat(for: baseline, named: "baseline", printPrefix: "____===>")
//    printStat(for: overhead, named: "overhead", printPrefix: "____===>")
    
    return adjustedMeasuredDuration / adjustedBaselineDuration
  }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //

  // MARK: - allRecordsForKey
  
  @Test(.serialized, arguments: BackingStorageKind.allCases)
  func allRecordsForKey(storageKind: BackingStorageKind) throws {
    let config = Config(iterations: iterations, innerLoopRange: innerLoopRange, storageKind: storageKind)
    
    var ratios: [Double] = []
    for run in 0...11 {
      let ratio = Self.allRecordsForKey_Ratio(config: config)
      if run == 0 { continue } // run 0 is preheat
      ratios.append(ratio)
    }
    
    let statSummary = statisticalSummary(of: ratios)
    // print("____ratios:", ratios.map { $0.rounded(toPlaces: 3) })
    // print("____median:", statSummary.median.rounded(toPlaces: 3))
    // printStatSummary(statSummary, named: "ratios", printPrefix: "____===>", fractionDigits: 3)
    let median = statSummary.median
    
    switch storageKind {
    case .singleForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        // 0.97
        // 1.12
      case .singleValue:
        #expect(median <= 0)
        // 2.7
        // 3.02
      }
    case .multiForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        // 1.67
        // 1.88
      case .singleValue:
        #expect(median <= 0)
        // 3.76
        // 4.26
      case .twoValues(let nilPosition):
        switch nilPosition {
        case .withoutNil:
          #expect(median <= 0)
          // 9.87
          // 10.93
        case .atStart:
          #expect(median <= 0)
          // 9.76
          // 10.8
        case .atEnd:
          #expect(median <= 0)
          // 9.77
          // 10.86
        }
      }
    }
  }
  
  @inline(never)
  static func allRecordsForKey_Ratio(config: Config) -> Double {
    let overhead = overheadMeasureOutput(config: config)
    
    let measured = performMeasuredAction(iterations: config.iterations, setup: { index in
      Self.makeIDKeyInstance(storageKind: config.storageKind, index: index)
    }, measure: { info in
      for _ in config.innerLoopRange {
        blackHole(info.allRecords(forKey: key))
      }
    })
    
    let baseline = baselineMeasureOutput(config: config)
    
    let adjustedMeasuredDuration = measured.medianDuration - overhead.medianDuration
    let adjustedBaselineDuration = baseline.medianDuration - overhead.medianDuration
    
    return adjustedMeasuredDuration / adjustedBaselineDuration
  }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //

  // MARK: - firstValueKey
  
  @Test(.serialized, arguments: BackingStorageKind.allCases)
  func firstValueForKey(storageKind: BackingStorageKind) throws {
    let config = Config(iterations: iterations, innerLoopRange: innerLoopRange, storageKind: storageKind)
    
    var ratios: [Double] = []
    for run in 0...3 {
      let ratio = Self.firstValueForKey_Ratio(config: config)
      if run == 0 { continue } // run 0 is preheat
      ratios.append(ratio)
    }
    
    let statSummary = statisticalSummary(of: ratios)
    // print("____ratios:", ratios.map { $0.rounded(toPlaces: 3) })
    // print("____median:", statSummary.median.rounded(toPlaces: 3))
    // printStatSummary(statSummary, named: "ratios", printPrefix: "____===>", fractionDigits: 3)
    let median = statSummary.median
    
    switch storageKind {
    case .singleForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        // 1.51 1.52
        //
      case .singleValue:
        #expect(median <= 0)
        // 2.77 2.72
        //
      }
    case .multiForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        // 2.08 2.06
        //
      case .singleValue:
        #expect(median <= 0)
        // 3.89 3.96
        //
      case .twoValues(let nilPosition):
        switch nilPosition {
        case .withoutNil:
          #expect(median <= 0)
          // 7.66 7.78
          //
        case .atStart:
          #expect(median <= 0)
          // 9.51 9.67
          //
        case .atEnd:
          #expect(median <= 0)
          // 7.70 7.70
          //
        }
      }
    }
  }
  
  @Test
  func firstValueForKey() throws {
    let storageKind: BackingStorageKind = .multiForKey(variant: .twoValues(nilPosition: .atEnd))
    let config = Config(iterations: iterations, innerLoopRange: innerLoopRange, storageKind: storageKind)
    
    let ratio = Self.firstValueForKey_Ratio(config: config)
    
    blackHole(ratio)
    
    
    // .multiForKey(variant: .twoValues(nilPosition: .atEnd))
    // 952
    // 1889
    
    // .multiForKey(variant: .twoValues(nilPosition: .atStart))
    // for index in indices.base + if count == 2
    // 1053
    // 2084
    // for index in indices
    // 1412
    // 2812
    // for index in indices.base
    // 1404
    // 2788
    
    // .multiForKey(variant: .singleValue)
    // 1103
    // 2182
    // =>
    // 889
    // 1760
    
    // .multiForKey(variant: .noValues)
    // 480
    // 946
    // =>
    // 380
    // 749
    
    // .singleForKey(variant: .noValues)
    // 382
    // 747
    // =>
    // 215
    // 405
    
    // .singleForKey(variant: .singleValue)
    // 799.833 800.578 804.198
    // 1590 1589 1589 1587
    
    // 1590us -> 0.00160000 20k calls -> 0.00080000 10k -> 0.000000080000
    //  800ms -> 0.00000008 | 1 call to firstValue(forKey:)
    // =>
    // 297
    // 577
  }
  
  @inline(never)
  static func firstValueForKey_Ratio(config: Config) -> Double {
    let overhead = overheadMeasureOutput(config: config)
    
    let measured = performMeasuredAction(iterations: config.iterations, setup: { index in
      Self.makeIDKeyInstance(storageKind: config.storageKind, index: index)
    }, measure: { info in
      for _ in config.innerLoopRange {
        blackHole(info.firstValue(forKey: key))
      }
    })
    
    let baseline = baselineMeasureOutput(config: config)
    
    print("____dur:", measured.totalDuration.inMilliseconds.asString(fractionDigits: 3))
    print("____durMedian:", measured.medianDuration.inMicroseconds.asString(fractionDigits: 3))
    
    let adjustedMeasuredDuration = measured.medianDuration - overhead.medianDuration
    let adjustedBaselineDuration = baseline.medianDuration - overhead.medianDuration
    
    return adjustedMeasuredDuration / adjustedBaselineDuration
  }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //

  // MARK: - lastValueForKey
  
  @Test(.serialized, arguments: BackingStorageKind.allCases)
  func lastValueForKey_Ratio(storageKind: BackingStorageKind) throws {
    let config = Config(iterations: iterations, innerLoopRange: innerLoopRange, storageKind: storageKind)
    
    var ratios: [Double] = []
    for run in 0...11 {
      let ratio = Self.lastValueForKey_Ratio(config: config)
      if run == 0 { continue } // run 0 is preheat
      ratios.append(ratio)
    }
    
    let statSummary = statisticalSummary(of: ratios)
    // print("____ratios:", ratios.map { $0.rounded(toPlaces: 3) })
    // print("____median:", statSummary.median.rounded(toPlaces: 3))
    // printStatSummary(statSummary, named: "ratios", printPrefix: "____===>", fractionDigits: 3)
    let median = statSummary.median
    
    switch storageKind {
    case .singleForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        // 1.33 1.34
        // 1.51
      case .singleValue:
        #expect(median <= 0)
        // 2.50 2.44
        // 2.71
      }
    case .multiForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        // 1.72 1.82
        // 1.95
      case .singleValue:
        #expect(median <= 0)
        // 3.45 3.53
        // 3.85
      case .twoValues(let nilPosition):
        switch nilPosition {
        case .withoutNil:
          #expect(median <= 0)
          // 6.77 6.98
          // 7.61
        case .atStart:
          #expect(median <= 0)
          // 6.77 6.94
          // 7.56
        case .atEnd:
          #expect(median <= 0)
          // 8.50 8.65
          // 9.48
        }
      }
    }
  }
  
  @inline(never)
  static func lastValueForKey_Ratio(config: Config) -> Double {
    let overhead = overheadMeasureOutput(config: config)
    
    let measured = performMeasuredAction(iterations: config.iterations, setup: { index in
      Self.makeIDKeyInstance(storageKind: config.storageKind, index: index)
    }, measure: { info in
      for _ in config.innerLoopRange {
        blackHole(info.lastValue(forKey: key))
      }
    })
    
    let baseline = baselineMeasureOutput(config: config)
    
    let adjustedMeasuredDuration = measured.medianDuration - overhead.medianDuration
    let adjustedBaselineDuration = baseline.medianDuration - overhead.medianDuration
    
    return adjustedMeasuredDuration / adjustedBaselineDuration
  }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //

  // MARK: - subscriptGetValueForKey
  
  @Test(.serialized, arguments: BackingStorageKind.allCases)
  func subscriptGetValueForKey(storageKind: BackingStorageKind) throws {
    let config = Config(iterations: iterations, innerLoopRange: innerLoopRange, storageKind: storageKind)
    
    var ratios: [Double] = []
    for run in 0...11 {
      let ratio = Self.subscriptGetValueForKey_Ratio(config: config)
      if run == 0 { continue } // run 0 is preheat
      ratios.append(ratio)
    }
    
    let statSummary = statisticalSummary(of: ratios)
    // print("____ratios:", ratios.map { $0.rounded(toPlaces: 3) })
    // print("____median:", statSummary.median.rounded(toPlaces: 3))
    // printStatSummary(statSummary, named: "ratios", printPrefix: "____===>", fractionDigits: 3)
    let median = statSummary.median
    
    switch storageKind {
    case .singleForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        //
        // 1.53 1.53
      case .singleValue:
        #expect(median <= 0)
        //
        // 2.72 2.73
      }
    case .multiForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        //
        // 1.95 2.08
      case .singleValue:
        #expect(median <= 0)
        //
        // 3.84 3.96
      case .twoValues(let nilPosition):
        switch nilPosition {
        case .withoutNil:
          #expect(median <= 0)
          //
          // 7.57 7.62
        case .atStart:
          #expect(median <= 0)
          //
          // 7.55 7.76
        case .atEnd:
          #expect(median <= 0)
          //
          // 9.47 9.57 9.66
        }
      }
    }
  }
  
  @inline(never)
  static func subscriptGetValueForKey_Ratio(config: Config) -> Double {
    let overhead = overheadMeasureOutput(config: config)
    
    let measured = performMeasuredAction(iterations: config.iterations, setup: { index in
      Self.makeIDKeyInstance(storageKind: config.storageKind, index: index)
    }, measure: { info in
      for _ in config.innerLoopRange {
        blackHole(info[dynamicKey: key])
      }
    })
    
    let baseline = baselineMeasureOutput(config: config)
    
    let adjustedMeasuredDuration = measured.medianDuration - overhead.medianDuration
    let adjustedBaselineDuration = baseline.medianDuration - overhead.medianDuration
    
    return adjustedMeasuredDuration / adjustedBaselineDuration
  }
  
  // ===-------------------------------------------------------------------------------------------------------------------=== //

  // MARK: - allValuesForKey
  
  @Test(.serialized, arguments: BackingStorageKind.allCases)
  func allValuesForKey(storageKind: BackingStorageKind) throws {
    let config = Config(iterations: iterations, innerLoopRange: innerLoopRange, storageKind: storageKind)
    
    var ratios: [Double] = []
    for run in 0...11 {
      let ratio = Self.allValuesForKey_Ratio(config: config)
      if run == 0 { continue } // run 0 is preheat
      ratios.append(ratio)
    }
    
    let statSummary = statisticalSummary(of: ratios)
    // print("____ratios:", ratios.map { $0.rounded(toPlaces: 3) })
    // print("____median:", statSummary.median.rounded(toPlaces: 3))
    // printStatSummary(statSummary, named: "ratios", printPrefix: "____===>", fractionDigits: 3)
    let median = statSummary.median
    
    switch storageKind {
    case .singleForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        // 1.28
        // 1.46
      case .singleValue:
        #expect(median <= 0)
        // 2.43
        // 2.72
      }
    case .multiForKey(let variant):
      switch variant {
      case .noValues:
        #expect(median <= 0)
        // 1.67
        // 2.01
      case .singleValue:
        #expect(median <= 0)
        // 3.53
        // 3.85
      case .twoValues(let nilPosition):
        switch nilPosition {
        case .withoutNil:
          #expect(median <= 0)
          // 9.7
          // 10.83
        case .atStart:
          #expect(median <= 0)
          // 8.26
          // 9.02
        case .atEnd:
          #expect(median <= 0)
          // 8.22
          // 9.15
        }
      }
    }
  }
  
  @inline(never)
  static func allValuesForKey_Ratio(config: Config) -> Double {
    let overhead = overheadMeasureOutput(config: config)
    
    let measured = performMeasuredAction(iterations: config.iterations, setup: { index in
      Self.makeIDKeyInstance(storageKind: config.storageKind, index: index)
    }, measure: { info in
      for _ in config.innerLoopRange {
        blackHole(info.allValues(forKey: key))
      }
    })
    
    let baseline = baselineMeasureOutput(config: config)
    
    let adjustedMeasuredDuration = measured.medianDuration - overhead.medianDuration
    let adjustedBaselineDuration = baseline.medianDuration - overhead.medianDuration
    
    return adjustedMeasuredDuration / adjustedBaselineDuration
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Helpers

extension ErrorInfoValueForKeyTests {
  struct Config {
    let iterations: Int
    let innerLoopRange: Range<Int>
    let storageKind: BackingStorageKind
  }
  
  enum BackingStorageKind: CaseIterable, CustomStringConvertible {
    /// OrderedDictionary
    case singleForKey(variant: SingleStorageValuesCount)
    
    /// OrderedMultiValueDictionary
    case multiForKey(variant: MultipleForKeyVariant)
    
    enum SingleStorageValuesCount {
      case noValues
      case singleValue
    }
    
    enum MultipleForKeyVariant {
      case noValues
      case singleValue
      case twoValues(nilPosition: NilPositionForKey)
    }
    
    enum NilPositionForKey {
      case withoutNil
      case atStart
      case atEnd
    }
    
    static var allCases: [Self] {
      [
        .singleForKey(variant: .noValues),
        .singleForKey(variant: .singleValue),
        .multiForKey(variant: .noValues),
        .multiForKey(variant: .singleValue), // underlying IndexSet is a single in-place value
        .multiForKey(variant: .twoValues(nilPosition: .withoutNil)), // underlying IndexSet is heap allocated
        .multiForKey(variant: .twoValues(nilPosition: .atStart)), // underlying IndexSet is heap allocated
        .multiForKey(variant: .twoValues(nilPosition: .atEnd)), // underlying IndexSet is heap allocated
      ]
    }
    
    var description: String {
      switch self {
      case .singleForKey(let variant):
        let valuesCount: String = switch variant {
        case .noValues: "0 values"
        case .singleValue: "1 value"
        }
        return "singl-storage " + valuesCount
        
      case .multiForKey(let variant):
        let valuesCount: String = switch variant {
        case .noValues: "0 values"
        case .singleValue: "1 value"
        case .twoValues(let nilPosition):
          switch nilPosition {
          case .withoutNil: "2 values without nil"
          case .atStart: "2 values nil at start"
          case .atEnd: "2 values nil at end"
          }
        }
        return "multi-storage " + valuesCount
      }
    }
  }
    
  @inlinable
  @inline(__always)
  internal static func makeIDKeyInstance(storageKind: BackingStorageKind, index: Int) -> ErrorInfo {
    var info = ErrorInfo()
    info[.name] = "name"
    
    switch storageKind {
    case .singleForKey(let valuesForTargetKeyCount):
      switch valuesForTargetKeyCount {
      case .noValues: break
      case .singleValue: info[.id] = index
      }
    case .multiForKey(let valuesForTargetKeyCount):
      switch valuesForTargetKeyCount {
      case .noValues:
        info[.name] = "name2" // trigger transition to multiValueForKey storage
        
      case .singleValue:
        info[.id] = index
        info[.name] = "name2" // trigger transition to multiValueForKey storage
        
      case .twoValues(let nilPosition):
        let range = 0..<2 // transition to multiValueForKey storage is triggered by multiple values added for key `.id`
        for number in range {
          let value: Int? = switch nilPosition {
          case .withoutNil: index + number
          case .atStart: number == range.first ? nil : index + number
          case .atEnd: number == range.last ? nil : index + number
          }
          info[.id] = value
        }
      }
    }
    return info
  }
  
  @inline(never)
  static func baselineMeasureOutput(config: Config) -> MeasureOutput<Void> {
    performMeasuredAction(iterations: config.iterations, setup: { index in
      var dict = Dictionary<String, ErrorInfo.ValueExistential>(minimumCapacity: 2)
      dict["name"] = "name"
      
      switch config.storageKind {
      case .singleForKey(let variant):
        switch variant {
        case .noValues: break
        case .singleValue: dict[key] = index
        }
      case .multiForKey(let variant):
        switch variant {
        case .noValues: break
        case .singleValue: dict[key] = index
        case .twoValues: dict[key] = index // dict can't have multiple values for key, so compare with subscript and 1 value
        }
      }
      return dict
    }, measure: { dict in
      for _ in config.innerLoopRange {
        blackHole(dict[key])
      }
    })
  }
  
  @inline(never)
  static func overheadMeasureOutput(config: Config) -> MeasureOutput<Void> {
    performMeasuredAction(iterations: config.iterations, setup: { index in
      makeIDKeyInstance(storageKind: config.storageKind, index: index)
    }, measure: { info in
      for _ in config.innerLoopRange {
        blackHole(info)
      }
    })
  }
}

func printStat<T>(for output: MeasureOutput<T>, named name: String, printPrefix: String) {
  let stat = statisticalSummary(of: output.measurements)
  lazy var statTrimmed = statisticalSummary(of: trimmedMeasurements(output.measurements, trimFraction: 0.2))
  
  printStatSummary(stat, named: name, printPrefix: printPrefix)
  printStatSummary(statTrimmed, named: name + "{trimmed}", printPrefix: printPrefix)
  print(printPrefix)
  print(printPrefix)
}

func printStatSummary(_ summary: StatisticalSummary<Duration>,
                      named name: String,
                      printPrefix: String,
                      fractionDigits: UInt8 = 1) {
  print(printPrefix,
        name,
        "values: min median mean max:",
        summary.minValue.inMicroseconds.asString(fractionDigits: fractionDigits),
        summary.median.inMicroseconds.asString(fractionDigits: fractionDigits),
        summary.mean.inMicroseconds.asString(fractionDigits: fractionDigits),
        summary.maxValue.inMicroseconds.asString(fractionDigits: fractionDigits))
  
  print(printPrefix,
        name,
        "deviation: mean std max:",
        summary.meanAbsoluteDeviation.inMicroseconds.asString(fractionDigits: fractionDigits),
        summary.standardDeviation.inMicroseconds.asString(fractionDigits: fractionDigits),
        summary.maxAbsDeviation.inMicroseconds.asString(fractionDigits: fractionDigits),
        "cv:",
        (summary.coefficientOfVariation * 100).asString(fractionDigits: 2) + "%")
}

func printStatSummary(_ summary: StatisticalSummary<Double>,
                      named name: String,
                      printPrefix: String,
                      fractionDigits: UInt8 = 1) {
  print(printPrefix,
        name,
        "values: min median mean max:",
        summary.minValue.asString(fractionDigits: fractionDigits),
        summary.median.asString(fractionDigits: fractionDigits),
        summary.mean.asString(fractionDigits: fractionDigits),
        summary.maxValue.asString(fractionDigits: fractionDigits))
  
  print(printPrefix,
        name,
        "deviation: mean std max:",
        summary.meanAbsoluteDeviation.asString(fractionDigits: fractionDigits),
        summary.standardDeviation.asString(fractionDigits: fractionDigits),
        summary.maxAbsDeviation.asString(fractionDigits: fractionDigits),
        "cv:",
        (summary.coefficientOfVariation * 100).asString(fractionDigits: 2) + "%",
        "maxRD:",
        (summary.maxRelativeDeviation * 100).asString(fractionDigits: 2) + "%")
}
