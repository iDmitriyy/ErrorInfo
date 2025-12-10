//
//  ErrorInfo+LegacyErrorInfo.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

import Foundation

extension ErrorInfo {
  //  public mutating func add(key: String, anyValue: Any, line: UInt = #line) {
  //    // use cases:
  //    // get value from [String: Any]. If it is Optional.nil, then type might be nknowm.
  //    // If not nil, it may be useful id instance from ObjC
  //    // >> need improvements as real Type can not always be known correctly.
  //    // May be the same approach for Optional as in isApproximatelyEqual
  //    var typeDescr: String { " (T.Type=" + "\(type(of: anyValue))" + ") " }
  //    _addValue(typeDescr + prettyDescription(any: anyValue), forKey: key, line: line)
  //  }
  
  public init(legacyUserInfo: [String: Any],
              collisionSource origin: @autoclosure () -> CollisionSource.Origin = .fileLine()) {
    self.init()
    
    legacyUserInfo.forEach { key, value in
      let interpolatedValue = Self.castOrConvertToSendable(legacyInfoValue: value)
      // Swift.Dictionary<String, Any> has unique keys with single value for key, so collision might never happen.
      // hardcode collisionSource: .onMerge(origin: .fileLine())
      _storage.appendResolvingCollisions(key: key,
                                         value: _Entry(optional: .value(interpolatedValue), keyOrigin: .dynamic),
                                         insertIfEqual: true,
                                         collisionSource: .onDictionaryConsumption(origin: origin()))
      // May be it is good to split into two separated dictionaries. Static initializer will return something like tuple of
      // (Self, nonSendableValues:)
    }
  }
}

extension ErrorInfo {
  internal static func castOrConvertToSendable(legacyInfoValue value: Any) -> any ErrorInfoValueType {
    // @inlining has no benefits for this func
    
    // For typical NSError, String value is most often used for a key, in general. Then NSNumber, URL, [String], [Any],
    // [String: Any].
    // So sort the switch this way to minimize casting overhead.
    
    switch value {
    case let value as String: value
    case let value as Bool: value
    case let value as Int: value
    case let value as UInt: value
    case let value as Double: value
    case let value as Float: value
    #if canImport(Foundation)
      case let value as URL: value
    #endif
    case let value as Int8: value
    case let value as Int16: value
    case let value as Int32: value
    case let value as Int64: value
    case let value as UInt8: value
    case let value as UInt16: value
    case let value as UInt32: value
    case let value as UInt64: value
    #if canImport(Foundation)
      case let value as Date: value
    #endif
    case let value as [String]: value
    //  case let value as [Any]: value.map(castOrConvertToSendable(legacyInfoValue:))
    //  case let value as [String: Any]: value.mapValues(castOrConvertToSendable(legacyInfoValue:))
    default: String(describing: value)
    }
  }
}
