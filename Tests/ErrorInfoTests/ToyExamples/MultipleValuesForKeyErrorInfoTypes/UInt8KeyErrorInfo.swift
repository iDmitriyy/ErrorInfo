//
//  UInt8KeyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 07/08/2025.
//

/// collisions are ressolved by adding an 1000
struct UInt8KeyErrorInfo {
  
}

extension UInt8KeyErrorInfo {
  enum PrimitiveValue {
    case string(String)
    case bool(Bool)
    case int(Int)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case uInt(UInt)
    case uInt8(UInt8)
    case uInt16(UInt16)
    case uInt32(UInt32)
    case float(Float)
    case float16(Float16)
    case float32(Float32)
  }
}

extension UInt8KeyErrorInfo {
  struct CustomKey {
    fileprivate let rawValue: UInt8
    
    private init(rawValue: UInt8) {
      self.rawValue = rawValue
    }
  }
}

// keys:
// range 1...9(<100)
// range 100..<200(<1000)
extension UInt8KeyErrorInfo.CustomKey {
  static let duration = Self(rawValue: 0)
  static let timestamp = Self(rawValue: 10)
  static let status = Self(rawValue: 20)
  static let code = Self(rawValue: 30)
  static let state = Self(rawValue: 40)
  static let value = Self(rawValue: 50)
  static let rawValue = Self(rawValue: 60)
  static let type = Self(rawValue: 70)
  static let index = Self(rawValue: 80)
  static let message = Self(rawValue: 90)
  static let name = Self(rawValue: 100)
  static let resource = Self(rawValue: 110)
}
