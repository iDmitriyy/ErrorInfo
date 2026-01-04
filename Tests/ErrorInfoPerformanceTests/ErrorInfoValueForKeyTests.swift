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
  private let factor: Double = 1
  
  private var iterations: Int {
    Int((Double(countBase) * factor).rounded(.toNearestOrAwayFromZero))
  }
  
  private let key = String(describing: StringLiteralKey.id)
  
  private let printPrefix = "____"
  
  @Test(.serialized, arguments: RecordAccessKind.allCases, StorageKind.allCases)
  func `get record`(accessKind: RecordAccessKind, storageKind: StorageKind) {
    if #available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *) {
      let overheadDuration = performMeasuredAction(iterations: iterations, setup: { index in
        makeIDKeyInstance(storageKind: storageKind, index: index)
      }, measure: { info in
        for _ in 0..<1000 {
          switch accessKind {
          case .lastRecorded: blackHole(info)
          case .allRecords: blackHole(info)
          }
        }
      }).duration
      
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
      
      let adjustedDuration = output.duration - overheadDuration
      
      printResult(adjustedDuration: adjustedDuration,
                  overheadDuration: overheadDuration,
                  accessKind: accessKind,
                  storageKind: storageKind)
      
      testByBaseline(accessKind: accessKind,
                     storageKind: storageKind,
                     adjustedDuration: adjustedDuration,
                     overheadDuration: overheadDuration)
    } // end if #available
  }
  
  private func testByBaseline(accessKind: RecordAccessKind,
                              storageKind: StorageKind,
                              adjustedDuration: Duration,
                              overheadDuration: Duration) {
    let baselineDuration = performMeasuredAction(iterations: iterations, setup: { index in
      [key: index, "name": "name"] as Dictionary<String, ErrorInfo.ValueExistential>
    }, measure: { dict in
      for _ in 0..<1000 {
        switch accessKind {
        case .lastRecorded: blackHole(dict[key])
        case .allRecords: blackHole(dict[key])
        }
      }
    }).duration - overheadDuration
    
    let ratio = adjustedDuration / baselineDuration
    
    /*
     ____    62.9    lastRecorded, singl-storage 0 values
     ____==== ratio: 0.7216639738551123    0.7133654346351713    0.7029623688719272
     ____    103.6    lastRecorded, singl-storage 1 value
     ____==== ratio: 1.1699557290508902    1.1819808938473508    1.1905649630061392
     ____    129.2    lastRecorded, multi-storage 0 values
     ____==== ratio: 1.4568665288731135    1.3531502340486605    1.3692049629517378
     ____    285.5    lastRecorded, multi-storage 1 value
     ____==== ratio: 3.2681981815822323    3.186690140246894    3.267836363473608
     ____    310.5    lastRecorded, multi-storage 2 values without nil
     ____==== ratio: 3.5358348993488997    3.420270609412708    3.504647616979162
     ____    310.3    lastRecorded, multi-storage 2 values nil at start
     ____==== ratio: 3.473993894473846    3.3991105996986306    3.5059747661910152
     ____    273.6    lastRecorded, multi-storage 2 values nil at end
     ____==== ratio: 3.095647950523024    2.9955600803212383    3.096027108439646
     ____    82.2    allRecords, singl-storage 0 values
     ____==== ratio: 0.9234815496961638   0.9122241464628474    0.915624802907003
     ____    260.3    allRecords, singl-storage 1 value
     ____==== ratio: 2.9353220373105007    2.9299742043558736    2.952386818042477
     ____    146.2    allRecords, multi-storage 0 values
     ____==== ratio: 1.6476868471828308    1.5419865837600137    1.5470718137565571
     ____    367.8    allRecords, multi-storage 1 value
     ____==== ratio: 4.164729052053808    4.12156451374267     4.162502589293339
     ____    969.1    allRecords, multi-storage 2 values without nil
     ____==== ratio: 10.940466894666416    10.870457570153606    11.005448627647498
     ____    957.8    allRecords, multi-storage 2 values nil at start
     ____==== ratio: 10.931777088672218    10.724172127280179    10.766528074706173
     ____    963.6    allRecords, multi-storage 2 values nil at end
     ____==== ratio: 11.00817323850178    10.872776583719006    10.892942192616886
     */
    
    print("____====", "ratio:", ratio)
  }
  
  @Test(.serialized, arguments: NonNilValueAccessKind.allCases, StorageKind.allCases)
  func `get non nil value`(accessKind: NonNilValueAccessKind, storageKind: StorageKind) {
    if #available(macOS 26.0, iOS 26.0, watchOS 26.0, tvOS 26.0, *) {
      
      let overheadDuration = performMeasuredAction(iterations: iterations, setup: { _ in
        make1000IDKeyInstances(storageKind: storageKind)
      }, measure: { infos in
        for index in infos.indices {
          switch accessKind {
          case .firstNonNil: blackHole(infos[index])
          case .lastNonNil: blackHole(infos[index])
          case .allNonNil: blackHole(infos[index])
          }
        }
      }).duration
      
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
      
      let adjustedDuration = output.duration - overheadDuration
      
      printResult(adjustedDuration: adjustedDuration,
                  overheadDuration: overheadDuration,
                  accessKind: accessKind,
                  storageKind: storageKind)
    } // end if #available
  }
  
  private func printResult(adjustedDuration: Duration,
                           overheadDuration: Duration,
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
