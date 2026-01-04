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
      
      printResult(duration: output.duration,
                  overheadDuration: overheadDuration,
                  accessKind: accessKind,
                  storageKind: storageKind)
    } // end if #available
  }
  
  @Test(.serialized, arguments: NonNilValueAccessKind.allCases, StorageKind.allCases)
  func `get non nil value`(accessKind: NonNilValueAccessKind, storageKind: StorageKind) {
    let iterations = Int((Double(countBase) * factor).rounded(.toNearestOrAwayFromZero))
    
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
      
      printResult(duration: output.duration,
                  overheadDuration: overheadDuration,
                  accessKind: accessKind,
                  storageKind: storageKind)
    } // end if #available
  }
  
  private func printResult(duration: Duration,
                           overheadDuration: Duration,
                           accessKind: some Any,
                           storageKind: some CustomStringConvertible) {
    let adjustedDuration = ((duration - overheadDuration).inMilliseconds).asString(fractionDigits: 1)
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
