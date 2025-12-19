//
//  StaticStringKeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

import ErrorInfo
import OrderedCollections

//struct StaticStringKeyErrorInfo: Sequence {
//  typealias Key = StaticString
//  typealias Value = ErrorInfo.ValueExistential
//  typealias Element = (key: Key, value: Value)
//  
//  private typealias MultiValueStorage = OrderedMultiValueErrorInfoGeneric<StaticStringHashableAdapter, Value>
//  
//  private var _storage: MultiValueStorage
//  
//  func makeIterator() -> some IteratorProtocol<Element> {
//    var iterator = _storage.makeIterator()
//    return AnyIterator {
//      guard let (key, warppedValue) = iterator.next() else { return nil }
//      return (key.base, warppedValue.value)
//    }
//  }
//}
//
//// MARK: StaticString Hashable Adapter
//
//fileprivate struct StaticStringHashableAdapter: Hashable {
//  let base: StaticString
//  
//  init(_ wrappedValue: StaticString) {
//    self.base = wrappedValue
//  }
//  
//  func hash(into hasher: inout Hasher) {
//    base.withUTF8Buffer { utf8Buffer in
//      for uint8 in utf8Buffer {
//        hasher.combine(uint8)
//      }
//    }
//  }
//
//  // TBD: this is not proper imp
//  static func == (lhs: StaticStringHashableAdapter, rhs: StaticStringHashableAdapter) -> Bool {
//    lhs.base.withUTF8Buffer { lhsBuffer in
//      rhs.base.withUTF8Buffer { rhsBuffer in
//        guard lhsBuffer.count == rhsBuffer.count else { return false }
//        
//        return lhsBuffer.enumerated().allSatisfy { index, byte in
//          byte == rhsBuffer[index]
//        }
//      }
//    }
//  }
//}
