//
//  ErrorInfoKeyValueLookupResultTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 11/01/2026.
//

import ErrorInfo
import Foundation
import OrderedCollections
import Testing

struct ErrorInfoKeyValueLookupResultTests {
  private static let key = String(describing: StringLiteralKey.id)
  private let key = String(describing: StringLiteralKey.id)
  
  private let measurementsCount: Int = 100
  
  private var iterations: Int {
    Int(Double(measurementsCount).rounded(.toNearestOrAwayFromZero))
  }
  
  private let innerLoopCount: Int = 20000 // 20000 is optimal for one measurement be ~= 450-800 µs
  private var innerLoopRange: Range<Int> { 0..<innerLoopCount }
  
  @Test(.serialized, arguments: BackingStorageKind.allCases)
  func keyValueLookupIncludingNil(storageKind: BackingStorageKind) throws {
    let config = IterationsConfig(iterations: iterations, innerLoopRange: innerLoopRange)
    
    let ratioSummary = collectRatioResults(runsCount: 9, shouldPreheat: true, getResult: {
      let measurements = collectMeasurements(overhead: {
        ErrorInfoKeyValueLookupResultTests.overheadMeasurement(config: config, storageKind: storageKind)
      }, baseline: {
        ErrorInfoKeyValueLookupResultTests.baselineMeasurement(config: config, storageKind: storageKind)
      }, measured: {
        ErrorInfoKeyValueLookupResultTests.keyValueLookupIncludingNilMeasurement(config: config, storageKind: storageKind)
      })
      return measurements.adjustedRatio
    })
    
    let medianRatio = ratioSummary.median
    
    switch storageKind {
    case .singleForKey(let valuesForKey):
      switch valuesForKey {
      case .noValues:
        #expect(medianRatio <= 0)
        // 0.49
        // 0.57 0.58 0.55 0.63
      case .singleValue:
        #expect(medianRatio <= 0)
        // 0.49
        // 0.56 0.56 0.54
      }
    case .multiForKey(let valuesForKey):
      switch valuesForKey {
      case .noValues:
        #expect(medianRatio <= 0)
        // 1.05
        // 1.22 1.22 1.1 1.28
      case .singleValue:
        #expect(medianRatio <= 0)
        // 1.77
        // 1.93 1.93 1.91 1.89
      case .twoValues(let nilPosition):
        switch nilPosition {
        case .withoutNil:
          #expect(medianRatio <= 0)
          // 2.18 2.16
          // 2.33 2.34 2.29
        case .atStart:
          #expect(medianRatio <= 0)
          // 2.04
          // 2.18 2.19 2.16 2.14
        case .atEnd:
          #expect(medianRatio <= 0)
          // 2.03 2.04
          // 2.18 2.18 2.20
        }
      }
    }
  }
    
  @inline(never)
  static func keyValueLookupIncludingNilMeasurement(config: IterationsConfig,
                                                    storageKind: BackingStorageKind) -> MeasureOutput<Void> {
    performMeasuredAction(iterations: config.iterations, setup: { index in
      makeIDKeyErrorInfo(storageKind: storageKind, index: index)
    }, measure: { info in
      for _ in config.innerLoopRange {
        blackHole(info.keyValueLookupResult(forKey: key))
      }
    })
  }
}

extension ErrorInfoKeyValueLookupResultTests {
  struct Config {
    let iterations: Int
    let innerLoopRange: Range<Int>
    let storageKind: BackingStorageKind
  }
  
  @inline(never)
  static func baselineMeasurement(config: IterationsConfig, storageKind: BackingStorageKind) -> MeasureOutput<Void> {
    performMeasuredAction(iterations: config.iterations, setup: { index in
      var dict = Dictionary<String, Array<Any?>>(minimumCapacity: 2)
      
      let nameArray: Array<Any?> = ["name"]
      dict["name"] = nameArray
      
      let idArray: Array<ErrorInfo.ValueExistential> = switch storageKind {
      case .singleForKey(let variant):
        switch variant {
        case .noValues: []
        case .singleValue: [index]
        }
      case .multiForKey(let variant):
        switch variant {
        case .noValues: []
        case .singleValue: [index]
        case .twoValues: [index, index]
        }
      }
      dict[key] = idArray
      return dict
    }, measure: { dict in
      for _ in config.innerLoopRange {
        var valuesCount: Int = 0
        var nilInstancesCount: Int = 0
        if let values = dict[key] {
          for value in values {
            if value == nil {
              nilInstancesCount += 1
            } else {
              valuesCount += 1
            }
          }
        }
        blackHole((valuesCount, nilInstancesCount))
      }
    })
  }
  
  @inline(never)
  static func overheadMeasurement(config: IterationsConfig, storageKind: BackingStorageKind) -> MeasureOutput<Void> {
    performMeasuredAction(iterations: config.iterations, setup: { index in
      makeIDKeyErrorInfo(storageKind: storageKind, index: index)
    }, measure: { info in
      for _ in config.innerLoopRange {
        blackHole(info)
      }
    })
  }
}

@inlinable
@inline(__always)
func collectRatioResults(runsCount: Int, shouldPreheat: Bool, getResult: () -> Double) -> StatisticalSummary<Double> {
  if shouldPreheat { blackHole(getResult()) }
  
  let rawResult = (0..<runsCount).map { _ in getResult() }
  
  return statisticalSummary(of: rawResult)
}


@inlinable
@inline(__always)
func collectMeasurements<O, M, B>(overhead: () -> MeasureOutput<O>,
                                  baseline: () -> MeasureOutput<B>,
                                  measured: () -> MeasureOutput<M>) -> CollectedOutputs<O, M, B> {
  CollectedOutputs(overhead: overhead(), baseline: baseline(), measured: measured())
}

@usableFromInline
struct IterationsConfig {
  let iterations: Int
  let innerLoopRange: Range<Int>
}

@usableFromInline
struct CollectedOutputs<O, M, B> {
  let overhead: MeasureOutput<O>
  let baseline: MeasureOutput<B>
  let measured: MeasureOutput<M>
  
  @usableFromInline
  init(overhead: MeasureOutput<O>, baseline: MeasureOutput<B>, measured: MeasureOutput<M>) {
    self.overhead = overhead
    self.baseline = baseline
    self.measured = measured
  }
  
  var adjustedMeasuredDuration: Duration { measured.medianDuration - overhead.medianDuration }
  
  var adjustedBaselineDuration: Duration { baseline.medianDuration - overhead.medianDuration }
  
  var adjustedRatio: Double { adjustedMeasuredDuration / adjustedBaselineDuration }
}


/*
 switch storageKind {
 case .singleForKey(let variant):
   switch variant {
   case .noValues:
     #expect(median <= 0)
     //
     //
   case .singleValue:
     #expect(median <= 0)
     //
     //
   }
 case .multiForKey(let variant):
   switch variant {
   case .noValues:
     #expect(median <= 0)
     //
     //
   case .singleValue:
     #expect(median <= 0)
     //
     //
   case .twoValues(let nilPosition):
     switch nilPosition {
     case .withoutNil:
       #expect(median <= 0)
       //
       //
     case .atStart:
       #expect(median <= 0)
       //
       //
     case .atEnd:
       #expect(median <= 0)
       //
       //
     }
   }
 }
 */
