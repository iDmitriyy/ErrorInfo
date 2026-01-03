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
  private let countBase: Int = 3000
  
  enum GetKind: CaseIterable {
    case allNonNil
    case firstNonNil
    case lastNonNil
    case lastRecorded
  }
  
  @Test(.serialized, arguments: [GetKind.lastRecorded], [false])
  mutating func `get values`(kind: GetKind, multipleValuesForKey: Bool) {
    let printPrefix = "____get \(kind):"
    
    let measurementsCount = countBase
    if #available(macOS 26.0, *) {
      let burdenDuration = performMeasuredAction(count: measurementsCount, prepare: { _ in
        make1000IDKeyInstances()
      }, measure: { infos in
        for index in infos.indices {
          switch kind {
          case .allNonNil: blackHole(infos[index])
          case .firstNonNil: blackHole(infos[index])
          case .lastNonNil: blackHole(infos[index])
          case .lastRecorded: blackHole(infos[index])
          }
        }
      }).duration
      
      let output = performMeasuredAction(count: measurementsCount, prepare: { _ in
        make1000IDKeyInstances()
      }, measure: { infos in
        for index in infos.indices {
          switch kind {
          case .allNonNil: blackHole(infos[index].allValues(forKey: "id"))
          case .firstNonNil: blackHole(infos[index].firstValue(forKey: "id"))
          case .lastNonNil: blackHole(infos[index].lastValue(forKey: "id"))
          case .lastRecorded: blackHole(infos[index].lastRecorded_2(forKey: "id"))
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
      
      let balancedDuration = (output.duration - burdenDuration).asString(fractionDigits: 2)
      print(printPrefix, balancedDuration, separator: "\t\t")
    } // end if #available
  }
  
  @available(macOS 26.0, *)
  @_transparent
  internal func make1000IDKeyInstances() -> InlineArray<1000, ErrorInfo> {
    InlineArray<1000, ErrorInfo>({ _ in [.id: "id", .name: "name", .name: "name2"] }) //, .id: "id2"
  }
}
