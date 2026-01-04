//
//  ErrorInfoValueForKeyTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 02/01/2026.
//

import ErrorInfo
import NonEmpty
import OrderedCollections
import Synchronization
import Testing

struct ErrorInfoValueForKeyTests {
  private let countBase: Int = 1000
  private let factor: Double = 10
  
  private var iterations: Int {
    Int((Double(countBase) * factor).rounded(.toNearestOrAwayFromZero))
  }
  
  private let key = String(describing: StringLiteralKey.id)
  
  private let printPrefix = "____"
  
  @Test(.serialized, arguments: RecordAccessKind.allCases, StorageKind.allCases)
  func `get record`(accessKind: RecordAccessKind, storageKind: StorageKind) {
    let dd = [
      [0.7056380032663495, 0.7063259911894273, 0.6925172413793104, 0.7083981337480559, 0.7088201037659266, 0.7286017699115044, 0.7073480623985318, 0.7088201037659266, 0.7088201037659266, 0.7077958694579545],
      [1.1449504532995993, 1.1615154185022027, 1.1233730459334756, 1.1466023858957666, 1.1581277672359267, 1.1557059279622188, 1.1510011612767006, 1.1556299559471366, 1.1554405968468469, 1.1554405968468469],
      [1.411781315074295, 1.415929203539823, 1.4762759859106291, 1.409741312469162, 1.5088412804856528, 1.4646878198567042, 1.3681959564541213, 1.3696804750459495, 1.3681959564541213, 1.3670707640259374],
      [3.249735673503912, 3.2493313626126126, 3.2758620689655173, 3.2468104602805385, 3.2390554617117115, 3.2496211453744492, 3.1967577092511013, 3.3191684608054213, 3.2334449339207048, 3.20507164537305],
      [3.505127753303965, 3.5066079295154187, 3.434560397817529, 3.5007224669603523, 3.504469313063063, 3.459001970720721, 3.480835745041293, 3.4757709251101323, 3.4744131951786845, 3.5940566104326956],
      [3.509533039647577, 3.51325309709526, 3.528075143311002, 3.5066079295154187, 3.503647577092511, 3.4661184442718995, 3.4684405286343614, 3.584549235215338, 3.4720996717608443, 3.5800176211453745],
      [3.086789256344192, 3.179437405145943, 3.103448275862069, 3.173398181433707, 3.1880594910833864, 3.1556651982378856, 3.060193832599119, 3.072140534426693, 3.072073024599986, 3.173251101321586],
      [0.96331148234299, 0.9573642042847563, 0.9439655172413793, 0.9559808275181504, 0.9559808275181504, 0.9134994369369369, 0.9148193832599119, 0.9176225602654149, 0.9148193832599119, 0.9148193832599119],
      [3.055896243039402, 3.0456005364768997, 2.979901926928655, 3.0353140198773527, 3.0324240501867905, 2.9383259911894273, 2.933983179082943, 2.9411993082271555, 2.9368458149779735, 2.9383259911894273],
      [1.5991753013322056, 1.688243391098719, 1.6705228261620277, 1.5874039613730881, 1.5874039613730881, 1.5447753303964757, 1.543330396475771, 1.6431944738140551, 1.5447753303964757, 1.6440671984188608],
      [4.092447916666667, 4.083859810115413, 4.102, 4.073589101048247, 4.070592796221893, 4.014696035242291, 4.039634361544434, 4.048564965361233, 4.035384506942976, 4.136528634361233],
      [10.869669415662226, 10.957470087883387, 10.844706126113682, 10.850139413404863, 10.925495171636005, 10.875171806167401, 10.74593832599119, 10.776585606889492, 10.774758240982566, 10.743013215859031],
      [10.81153384626244, 10.836903963576042, 10.63609365287658, 10.737506167618243, 10.705223091562699, 10.640602456276172, 10.62847577092511, 10.786856315956658, 10.68541982846857, 10.647577092511014],
      [10.939472012423238, 10.792750502947094, 10.802990538020582, 10.75390625, 10.761013604003665, 10.649774774774775, 10.624070484581498, 10.77955034765115, 10.6920067667583, 10.619665198237886],
    ]
    
    let average = averageWithDelta(dd)
    
    for average in average {
      print("____–––",
            average.average.asString(fractionDigits: 4),
            "delta average/min/max",
            average.averageDelta.asString(fractionDigits: 4),
            average.minDelta.asString(fractionDigits: 4),
            average.maxDelta.asString(fractionDigits: 4))
    }
    
    if #available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *) {
      let overhead = performMeasuredAction(iterations: iterations, setup: { index in
        makeIDKeyInstance(storageKind: storageKind, index: index)
      }, measure: { info in
        for _ in 0..<1000 {
          switch accessKind {
          case .lastRecorded: blackHole(info)
          case .allRecords: blackHole(info)
          }
        }
      })
      
      let output = performMeasuredAction(iterations: iterations, setup: { index in
        makeIDKeyInstance(storageKind: storageKind, index: index)
      }, measure: { info in
        for _ in 0..<1000 {
          switch accessKind {
          case .lastRecorded: blackHole(info.lastRecorded(forKey: key))
          case .allRecords: blackHole(info.allRecords(forKey: key))
          }
        }
      })
      
      /*
        20.95    lastRecorded, singl-storage 0 values
        34.32    lastRecorded, singl-storage 1 value
        39.69    lastRecorded, multi-storage 0 values
        95.21    lastRecorded, multi-storage 1 value
       102.22    lastRecorded, multi-storage 2 values without nil
       101.74    lastRecorded, multi-storage 2 values nil at start
        90.05    lastRecorded, multi-storage 2 values nil at end
       
        26.91    allRecords, singl-storage 0 values
        85.19    allRecords, singl-storage 1 value
        45.17    allRecords, multi-storage 0 values
       120.49    allRecords, multi-storage 1 value
       321.49    allRecords, multi-storage 2 values without nil
       318.40    allRecords, multi-storage 2 values nil at start
       316.15    allRecords, multi-storage 2 values nil at end
       */
      
      printResult(adjustedDuration: output.totalDuration - overhead.totalDuration,
                  accessKind: accessKind,
                  storageKind: storageKind)
      
      testByBaseline(accessKind: accessKind,
                     storageKind: storageKind,
                     adjustedDuration: output.medianDuration - overhead.medianDuration,
                     overheadDuration: overhead.medianDuration)
    } // end if #available
  }
  
  private func testByBaseline(accessKind: RecordAccessKind,
                              storageKind: StorageKind,
                              adjustedDuration: Duration,
                              overheadDuration: Duration) {
    let baseline = performMeasuredAction(iterations: iterations, setup: { index in
      [key: index, "name": "name"] as Dictionary<String, ErrorInfo.ValueExistential>
    }, measure: { dict in
      for _ in 0..<1000 {
        switch accessKind {
        case .lastRecorded: blackHole(dict[key])
        case .allRecords: blackHole(dict[key])
        }
      }
    })
    
    let adjustedBaselineDuration = baseline.medianDuration - overheadDuration
    
    let ratio = adjustedDuration / adjustedBaselineDuration
    
//    print("____", adjustedDuration.inMicroseconds, overheadDuration.inMicroseconds, adjustedBaselineDuration.inMicroseconds)
    
    /*
     Average:
      0.7083 delta average/min/max 0.0044 0.0001 0.0203
      1.1508 delta average/min/max 0.0075 0.0002 0.0274
      1.4160 delta average/min/max 0.0403 0.0001 0.0928
      3.2465 delta average/min/max 0.0223 0.0003 0.0727
      3.4936 delta average/min/max 0.0286 0.0072 0.1005
      3.5132 delta average/min/max 0.0306 0.0000 0.0713
      3.1264 delta average/min/max 0.0475 0.0230 0.0663
     
      0.9352 delta average/min/max 0.0201 0.0087 0.0281
      2.9838 delta average/min/max 0.0468 0.0039 0.0721
      1.6053 delta average/min/max 0.0450 0.0061 0.0830
      4.0697 delta average/min/max 0.0281 0.0009 0.0668
     10.8363 delta average/min/max 0.0610 0.0084 0.1212
     10.7116 delta average/min/max 0.0653 0.0064 0.1253
     10.7415 delta average/min/max 0.0761 0.0124 0.1980
     
     ____==== ratio: 0.7056380032663495 + 0.7063259911894273 + 0.6925172413793104 + 0.7083981337480559 + 0.7088201037659266
     ____==== ratio: 1.1449504532995993 + 1.1615154185022027 + 1.1233730459334756 + 1.1466023858957666 + 1.1581277672359267
     ____==== ratio: 1.411781315074295 + 1.415929203539823 + 1.4762759859106291 + 1.409741312469162 + 1.5088412804856528
     ____==== ratio: 3.249735673503912 + 3.2493313626126126 + 3.2758620689655173 + 3.2468104602805385 + 3.2390554617117115
     ____==== ratio: 3.505127753303965 + 3.5066079295154187 + 3.434560397817529 + 3.5007224669603523 + 3.504469313063063
     ____==== ratio: 3.509533039647577 + 3.51325309709526 + 3.528075143311002 + 3.5066079295154187 + 3.503647577092511
     ____==== ratio: 3.086789256344192 + 3.179437405145943 + 3.103448275862069 + 3.173398181433707 + 3.1880594910833864
     ____==== ratio: 0.96331148234299 + 0.9573642042847563 + 0.9439655172413793 + 0.9559808275181504 + 0.9559808275181504
     ____==== ratio: 3.055896243039402 + 3.0456005364768997 + 2.979901926928655 + 3.0353140198773527 + 3.0324240501867905
     ____==== ratio: 1.5991753013322056 + 1.688243391098719 + 1.6705228261620277 + 1.5874039613730881 + 1.5874039613730881
     ____==== ratio: 4.092447916666667 + 4.083859810115413 + 4.102 + 4.073589101048247 + 4.070592796221893
     ____==== ratio: 10.869669415662226 + 10.957470087883387 + 10.844706126113682 + 10.850139413404863 + 10.925495171636005
     ____==== ratio: 10.81153384626244 + 10.836903963576042 + 10.63609365287658 + 10.737506167618243 + 10.705223091562699
     ____==== ratio: 10.939472012423238 + 10.792750502947094 + 10.802990538020582 + 10.75390625 + 10.761013604003665
     */
    
    print("____====", "ratio:", ratio)
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
      
      let output = performMeasuredAction(iterations: iterations, setup: { _ in
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
      
      /*
       allNonNil:    289.38
       firstNonNil:    296.18
       lastNonNil:    296.58
       lastRecorded:    334.69
       */
            
      printResult(adjustedDuration: output.totalDuration - overhead.totalDuration,
                  accessKind: accessKind,
                  storageKind: storageKind)
    } // end if #available
  }
  
  private func printResult(adjustedDuration: Duration,
                           accessKind: some Any,
                           storageKind: some CustomStringConvertible) {
    let adjustedDuration = (adjustedDuration.inMilliseconds).asString(fractionDigits: 1)
    print(printPrefix, adjustedDuration, "\(accessKind), \(storageKind)", separator: "\t\t")
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
