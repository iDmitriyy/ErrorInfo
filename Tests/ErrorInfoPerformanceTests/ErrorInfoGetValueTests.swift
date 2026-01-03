//
//  ErrorInfoGetValueTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 02/01/2026.
//

import ErrorInfo
import NonEmpty
import OrderedCollections
import Synchronization
import Testing

struct ErrorInfoGetValueTests {
  private let countBase: Int = 1000
  private let printPrefix = "____valuesForKey"
  private let idKey = "id"
  
  private let factor: Double = 1
  
  enum InfoStorageKind {
    case singleForKey
    case multiForKey(valuesForKeyCount: Int)
  }
  
  enum RetrievalKind: CaseIterable {
    case allNonNil
    case allRecords
    case firstNonNil
    case lastNonNil
    case lastRecorded
  }
  
  @Test(.serialized, arguments: RetrievalKind.allCases, [false])
  func `get values`(retrievalKind: RetrievalKind, multipleValuesForKey _: Bool) {
    let iterations = Int((Double(countBase) * factor).rounded(.toNearestOrAwayFromZero))
    
    if #available(macOS 26.0, *) {
      let overheadDuration = performMeasuredAction(iterations: iterations, setup: { _ in
        make1000IDKeyInstances()
      }, measure: { infos in
        for index in infos.indices {
          switch retrievalKind {
          case .allNonNil: blackHole(infos[index])
          case .allRecords: blackHole(infos[index])
          case .firstNonNil: blackHole(infos[index])
          case .lastNonNil: blackHole(infos[index])
          case .lastRecorded: blackHole(infos[index])
          }
        }
      }).duration
      
      let output = performMeasuredAction(iterations: iterations, setup: { _ in
        make1000IDKeyInstances()
      }, measure: { infos in
        for index in infos.indices {
          switch retrievalKind {
          case .allNonNil: blackHole(infos[index].allValues(forKey: idKey))
          case .allRecords: blackHole(infos[index].allRecords(forKey: idKey))
          case .firstNonNil: blackHole(infos[index].firstValue(forKey: idKey))
          case .lastNonNil: blackHole(infos[index].lastValue(forKey: idKey))
          case .lastRecorded: blackHole(infos[index].lastRecorded_2(forKey: idKey))
          }
        }
      })
      
      /*
       270.98 [0]
       
       allNonNil:    289.38
       firstNonNil:    296.18
       lastNonNil:    296.58
       lastRecorded:    334.69
       */
      
      let adjustedDuration = ((output.duration - overheadDuration).inMilliseconds / factor).asString(fractionDigits: 2)
      print(printPrefix + " \(retrievalKind):", adjustedDuration, separator: "\t\t")
    } // end if #available
  }
  
  @available(macOS 26.0, *)
  @_transparent
  internal func make1000IDKeyInstances() -> InlineArray<1000, ErrorInfo> {
    InlineArray<1000, ErrorInfo>({ _ in [.id: "id", .name: "name"] }) // , .id: "id2" , .name: "name2"
  }
}
