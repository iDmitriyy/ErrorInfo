//
//  CastToSendableTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 10/12/2025.
//

import ErrorInfo
import Testing

struct CastToSendableTests {
  let values: [Any] = [
    true as Bool,
    0 as Int,
    0 as Int8,
    0 as Int16,
    0 as Int32,
    0 as Int64,
    0 as UInt,
    0 as UInt8,
    0 as UInt16,
    0 as UInt32,
    0 as UInt64,
    0 as Float,
    0 as Double,
    "String" as String,
  ]
  
  
  @Test func basic() {
    var input = values
    for _ in 1...10 {
      input += values.shuffled()
    }
    
//    let count = 100
//    let output1 = performMeasuredAction(count: count) {
//      for value in input {
//        blackHole(castToSendable_1(input))
//      }
//    }
//    
//    let output2 = performMeasuredAction(count: count) {
//      for value in input {
//        blackHole(castToSendable_2(input))
//      }
//    }
//    
//    let output3 = performMeasuredAction(count: count) {
//      for value in input {
//        blackHole(castToSendable_3(input))
//      }
//    }
    
    // print(">> castToSendable: ", output1.duration, output2.duration, output3.duration)
    
    /*
    Release:
     >> checkSendable:  89.092205 8.517497 3.57954
     >> checkSendable:  89.107581 2.461712 2.456001 (+ @inline(__always))
     
     >> castToSendable:  1437.106994 1441.414249 1427.381083
     >> castToSendable:  1409.792167 1403.650082 1405.533163 (+ @inline(__always))
     
    Debug:
     >> checkSendable:  101.91000600000001 20.800584 15.604747000000001
     */
  }
}

/*
 public func castToSendable_1(_ value: Any) -> any Sendable {
   switch value {
   case let value as Bool: value
   case let value as Int: value
   case let value as Int8: value
   case let value as Int16: value
   case let value as Int32: value
   case let value as Int64: value
   case let value as UInt: value
   case let value as UInt8: value
   case let value as UInt16: value
   case let value as UInt32: value
   case let value as UInt64: value
   case let value as Float: value
   case let value as Double: value
   case let value as String: value
   default: String(describing: value)
   }
 }

  @inlinable @inline(__always)
 public func castToSendable_2<T>(_ value: T) -> any Sendable {
   switch T.self {
   case is Bool.Type: __forceCast(value, to: Bool.self)
   case is Int.Type: __forceCast(value, to: Int.self)
   case is Int8.Type: __forceCast(value, to: Int8.self)
   case is Int16.Type: __forceCast(value, to: Int16.self)
   case is Int32.Type: __forceCast(value, to: Int32.self)
   case is Int64.Type: __forceCast(value, to: Int64.self)
   case is UInt.Type: __forceCast(value, to: UInt.self)
   case is UInt8.Type: __forceCast(value, to: UInt8.self)
   case is UInt16.Type: __forceCast(value, to: UInt16.self)
   case is UInt32.Type: __forceCast(value, to: UInt32.self)
   case is UInt64.Type: __forceCast(value, to: UInt64.self)
   case is Float.Type: __forceCast(value, to: Float.self)
   case is Double.Type: __forceCast(value, to: Double.self)
   case is String.Type: __forceCast(value, to: String.self)
   default: String(describing: value)
   }
 }

 @inlinable @inline(__always)
 internal func __forceCast<T, U>(_ value: T, to _: U.Type) -> U {
   value as! U
 }

  @inlinable @inline(__always)
 public func castToSendable_3<T>(_ value: T) -> any Sendable {
   if T.self == Bool.self { return unsafeBitCast(value, to: Bool.self) }
   if T.self == Int.self { return unsafeBitCast(value, to: Int.self) }
   if T.self == Int8.self { return unsafeBitCast(value, to: Int8.self) }
   if T.self == Int16.self { return unsafeBitCast(value, to: Int16.self) }
   if T.self == Int32.self { return unsafeBitCast(value, to: Int32.self) }
   if T.self == Int64.self { return unsafeBitCast(value, to: Int64.self) }
   if T.self == UInt.self { return unsafeBitCast(value, to: UInt.self) }
   if T.self == UInt8.self { return unsafeBitCast(value, to: UInt8.self) }
   if T.self == UInt16.self { return unsafeBitCast(value, to: UInt16.self) }
   if T.self == UInt32.self { return unsafeBitCast(value, to: UInt32.self) }
   if T.self == UInt64.self { return unsafeBitCast(value, to: UInt64.self) }
   if T.self == Float.self { return unsafeBitCast(value, to: Float.self) }
   if T.self == Double.self { return unsafeBitCast(value, to: Double.self) }
   if T.self == String.self { return unsafeBitCast(value, to: String.self) }
   
   return String(describing: value)
 }
 */

/*
@inlinable @inline(__always)
public func checkSendable_1(_ value: Any) -> Bool {
  switch value {
  case let value as Bool: true
  case let value as Int: true
  case let value as Int8: true
  case let value as Int16: true
  case let value as Int32: true
  case let value as Int64: true
  case let value as UInt: true
  case let value as UInt8: true
  case let value as UInt16: true
  case let value as UInt32: true
  case let value as UInt64: true
  case let value as Float: true
  case let value as Double: true
  case let value as String: true
  case let value as any CustomStringConvertible: false
  default: false
  }
}

@inlinable @inline(__always)
public func checkSendable_2<T>(_ value: T) -> Bool {
  switch T.self {
  case is Bool.Type: true
  case is Int.Type: true
  case is Int8.Type: true
  case is Int16.Type: true
  case is Int32.Type: true
  case is Int64.Type: true
  case is UInt.Type: true
  case is UInt8.Type: true
  case is UInt16.Type: true
  case is UInt32.Type: true
  case is UInt64.Type: true
  case is Float.Type: true
  case is Double.Type: true
  case is String.Type: true
  case is CustomStringConvertible.Protocol: false
  default: false
  }
}

@inlinable @inline(__always)
public func checkSendable_3<T>(_ value: T) -> Bool {
  if T.self == Bool.self { return true }
  if T.self == Int.self { return true }
  if T.self == Int8.self { return true }
  if T.self == Int16.self { return true }
  if T.self == Int32.self { return true }
  if T.self == Int64.self { return true }
  if T.self == UInt.self { return true }
  if T.self == UInt8.self { return true }
  if T.self == UInt16.self { return true }
  if T.self == UInt32.self { return true }
  if T.self == UInt64.self { return true }
  if T.self == Float.self { return true }
  if T.self == Double.self { return true }
  if T.self == String.self { return true }
  if T.self == (any CustomStringConvertible).self { return true }
  return false
}
*/
