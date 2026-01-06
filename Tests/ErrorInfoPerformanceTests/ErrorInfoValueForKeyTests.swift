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

struct ErrorInfoValueForKeyTests {
  private let countBase: Int = 1000
  private let factor: Double = 1
  
  private var iterations: Int {
    Int((Double(countBase) * factor).rounded(.toNearestOrAwayFromZero))
  }
  
  private let innerLoopCount: Int = 2000 // 2000 is optimal for one measurement be ~= 50-70 µs
  
  private let key = String(describing: StringLiteralKey.id)
  
  private let printPrefix = "____"
  
  @Test(.serialized, arguments: RecordAccessKind.allCases, StorageKind.allCases)
  func `get record`(accessKind: RecordAccessKind, storageKind: StorageKind) {
    if #available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *) {
      let workloadFactor: Int = switch accessKind {
      case .lastRecorded:
        switch storageKind {
        case .singleForKey: 1
        case .multiForKey(let variant):
          switch variant {
          case .noValues: 1
          case .singleValue: 2
          case .twoValues: 2
          }
        }
      case .allRecords:
        switch storageKind {
        case .singleForKey(let variant):
          switch variant {
          case .noValues: 1
          case .singleValue: 2
          }
        case .multiForKey(let variant):
          switch variant {
          case .noValues: 1
          case .singleValue: 2
          case .twoValues: 5
          }
        }
      }
      
      let overhead = performMeasuredAction(iterations: iterations, setup: { index in
        makeIDKeyInstance(storageKind: storageKind, index: index)
      }, measure: { info in
        for _ in 0..<innerLoopCount {
          switch accessKind {
          case .lastRecorded: blackHole(info)
          case .allRecords: blackHole(info)
          }
        }
      })
      
      let workloadAdjustedIterations = iterations / workloadFactor
      
      let measured = performMeasuredAction(iterations: workloadAdjustedIterations, setup: { index in
        makeIDKeyInstance(storageKind: storageKind, index: index)
      }, measure: { info in
        for _ in 0..<innerLoopCount {
          switch accessKind {
          case .lastRecorded: blackHole(info.lastRecorded(forKey: key))
          case .allRecords: blackHole(info.allRecords(forKey: key))
          }
        }
      })
      
      printResult(measured: measured, overhead: overhead, accessKind: accessKind, storageKind: storageKind)
      
      testByBaseline(measured: measured, overhead: overhead, accessKind: accessKind, storageKind: storageKind)
    } // end if #available
  }
  
  private func testByBaseline(measured: MeasureOutput<Void>,
                              overhead: MeasureOutput<Void>,
                              accessKind: RecordAccessKind,
                              storageKind: StorageKind) {
    let baseline = performMeasuredAction(iterations: iterations, setup: { index in
      var dict = Dictionary<String, ErrorInfo.ValueExistential>(minimumCapacity: 2)
      dict["name"] = "name"
      switch storageKind {
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
      for _ in 0..<innerLoopCount {
        switch accessKind {
        case .lastRecorded: blackHole(dict[key])
        case .allRecords: blackHole(dict[key])
        }
      }
    })
    
    let adjustedDuration = measured.medianDuration - overhead.medianDuration
    let adjustedBaselineDuration = baseline.medianDuration - overhead.medianDuration
    
    // the average / median ratio is within tolerance
    // occasionally the ratio jumps to ~2 × tolerance
    // – outliers, not noise. Adaptive tolerance alone cannot eliminate them
    
    let ratio = adjustedDuration / adjustedBaselineDuration
    
//    print("____", adjustedDuration.inMicroseconds, overheadDuration.inMicroseconds, adjustedBaselineDuration.inMicroseconds)
//    print("____====", "\(accessKind), \(storageKind)", "ratio:", ratio.asString(fractionDigits: 3))
    
    print("____====", "ratio:", ratio.asString(fractionDigits: 3))
    
    measured.averageDuration
    measured.medianDuration
    
    print("____===>")
    
    /*
     Average:
     
      0.891, 0.784,  0.862,                 .
      1.182, 1.059,  1.183,                 .
      1.656, 1.570,  1.779,                 .
      3.214, 2.914,  3.321,                 .
      3.415, 3.266,  3.594,                 .
      3.503, 3.031,  3.605,                 .
      3.120, 3.007,  3.271,                 .
      1.109, 0.983,  1.065,                 .
      2.955, 2.711,  3.001,                 .
      1.873, 1.675,  1.973,                 .
      4.121, 3.792,  4.227,                 .
     10.941, 9.868, 11.144,                 .
     10.868, 9.700, 10.854,                 .
     10.833, 9.648, 10.903,                 .
     
     */
    
    // Absolute duration for single iteration:
//     print(">>>> min", ContinuousClock().minimumResolution.inMicroseconds)
//     print(">>>> measured", "\(accessKind), \(storageKind)", measured.medianDuration.inMicroseconds)
//     print(">>>> baseline", "\(accessKind), \(storageKind)", baseline.medianDuration.inMicroseconds)
  }
  
  @Test(.serialized, arguments: NonNilValueAccessKind.allCases, StorageKind.allCases)
  func `get non nil value`(accessKind: NonNilValueAccessKind, storageKind: StorageKind) {
    if #available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *) {
      
      let overhead = performMeasuredAction(iterations: iterations, setup: { _ in
        make1000IDKeyInstances(storageKind: storageKind)
      }, measure: { infos in
        for index in infos.indices {
          switch accessKind {
          case .firstNonNil: blackHole(infos[index])
          case .lastNonNil: blackHole(infos[index])
          case .allNonNil: blackHole(infos[index])
          }
        }
      })
      
      let measured = performMeasuredAction(iterations: iterations, setup: { _ in
        make1000IDKeyInstances(storageKind: storageKind)
      }, measure: { infos in
        for index in infos.indices {
          switch accessKind {
          case .firstNonNil: blackHole(infos[index].firstValue(forKey: key))
          case .lastNonNil: blackHole(infos[index].lastValue(forKey: key))
          case .allNonNil: blackHole(infos[index].allValues(forKey: key))
          }
        }
      })
            
      printResult(measured: measured, overhead: overhead, accessKind: accessKind, storageKind: storageKind)
    } // end if #available
  }
  
  private func printResult(measured: MeasureOutput<Void>,
                           overhead: MeasureOutput<Void>,
                           accessKind: some Any,
                           storageKind: some CustomStringConvertible) {
    let adjustedDuration = ((measured.totalDuration - overhead.totalDuration).inMilliseconds).asString(fractionDigits: 1)
    print(printPrefix, adjustedDuration, "\(accessKind), \(storageKind)", separator: "\t\t")
  }
  
  @Test func calc() {
    //    let dd = [
    //      [0.7056380032663495, 0.7063259911894273, 0.6925172413793104, 0.7083981337480559, 0.7088201037659266, 0.7286017699115044, 0.7073480623985318, 0.7088201037659266, 0.7088201037659266, 0.7077958694579545],
    //      [1.1449504532995993, 1.1615154185022027, 1.1233730459334756, 1.1466023858957666, 1.1581277672359267, 1.1557059279622188, 1.1510011612767006, 1.1556299559471366, 1.1554405968468469, 1.1554405968468469],
    //      [1.411781315074295, 1.415929203539823, 1.4762759859106291, 1.409741312469162, 1.5088412804856528, 1.4646878198567042, 1.3681959564541213, 1.3696804750459495, 1.3681959564541213, 1.3670707640259374],
    //      [3.249735673503912, 3.2493313626126126, 3.2758620689655173, 3.2468104602805385, 3.2390554617117115, 3.2496211453744492, 3.1967577092511013, 3.3191684608054213, 3.2334449339207048, 3.20507164537305],
    //      [3.505127753303965, 3.5066079295154187, 3.434560397817529, 3.5007224669603523, 3.504469313063063, 3.459001970720721, 3.480835745041293, 3.4757709251101323, 3.4744131951786845, 3.5940566104326956],
    //      [3.509533039647577, 3.51325309709526, 3.528075143311002, 3.5066079295154187, 3.503647577092511, 3.4661184442718995, 3.4684405286343614, 3.584549235215338, 3.4720996717608443, 3.5800176211453745],
    //      [3.086789256344192, 3.179437405145943, 3.103448275862069, 3.173398181433707, 3.1880594910833864, 3.1556651982378856, 3.060193832599119, 3.072140534426693, 3.072073024599986, 3.173251101321586],
    //      [0.96331148234299, 0.9573642042847563, 0.9439655172413793, 0.9559808275181504, 0.9559808275181504, 0.9134994369369369, 0.9148193832599119, 0.9176225602654149, 0.9148193832599119, 0.9148193832599119],
    //      [3.055896243039402, 3.0456005364768997, 2.979901926928655, 3.0353140198773527, 3.0324240501867905, 2.9383259911894273, 2.933983179082943, 2.9411993082271555, 2.9368458149779735, 2.9383259911894273],
    //      [1.5991753013322056, 1.688243391098719, 1.6705228261620277, 1.5874039613730881, 1.5874039613730881, 1.5447753303964757, 1.543330396475771, 1.6431944738140551, 1.5447753303964757, 1.6440671984188608],
    //      [4.092447916666667, 4.083859810115413, 4.102, 4.073589101048247, 4.070592796221893, 4.014696035242291, 4.039634361544434, 4.048564965361233, 4.035384506942976, 4.136528634361233],
    //      [10.869669415662226, 10.957470087883387, 10.844706126113682, 10.850139413404863, 10.925495171636005, 10.875171806167401, 10.74593832599119, 10.776585606889492, 10.774758240982566, 10.743013215859031],
    //      [10.81153384626244, 10.836903963576042, 10.63609365287658, 10.737506167618243, 10.705223091562699, 10.640602456276172, 10.62847577092511, 10.786856315956658, 10.68541982846857, 10.647577092511014],
    //      [10.939472012423238, 10.792750502947094, 10.802990538020582, 10.75390625, 10.761013604003665, 10.649774774774775, 10.624070484581498, 10.77955034765115, 10.6920067667583, 10.619665198237886],
    //    ]
    // [10.93, 10.79, 10.82]
    //    let average = averageWithDelta(dd)
        
    //    for average in average {
    //      print("____–––",
    //            average.average.asString(fractionDigits: 4),
    //            "delta average/min/max/max%",
    //            average.averageDelta.asString(fractionDigits: 4),
    //            average.minDelta.asString(fractionDigits: 4),
    //            average.maxDelta.asString(fractionDigits: 4))
    //    }
  }
}

extension ErrorInfoValueForKeyTests {
  enum SingleStorageValuesCount {
    case noValues
    case singleValue
  }
  
  enum StorageKind: CaseIterable, CustomStringConvertible {
    /// OrderedDictionary
    case singleForKey(variant: SingleStorageValuesCount)
    
    /// OrderedMultiValueDictionary
    case multiForKey(variant: MultipleForKeyVariant)
    
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
  
  enum RecordAccessKind: CaseIterable {
    case lastRecorded
    case allRecords
  }
  
  enum NonNilValueAccessKind: CaseIterable {
    case firstNonNil
    case lastNonNil
    case allNonNil
  }
  
  @inlinable
  @inline(__always)
  @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *)
  internal func make1000IDKeyInstances(storageKind: StorageKind) -> InlineArray<1000, ErrorInfo> {
    InlineArray<1000, ErrorInfo>({ index in
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
    })
  }
  
  @inlinable
  @inline(__always)
  @available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *)
  internal func makeIDKeyInstance(storageKind: StorageKind, index: Int) -> ErrorInfo {
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
}
