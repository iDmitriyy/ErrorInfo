//
//  ErrorInfo+LegacyErrorInfo.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

import Foundation

extension ErrorInfo {
  /// Initializes an `ErrorInfo` instance using a legacy user info dictionary.
  ///
  /// This initializer takes a dictionary with legacy  `[String: Any]` dictionary,
  /// processes each key-value pair, and converts the values to a compatible type.
  ///
  /// - Parameters:
  ///   - legacyUserInfo: A dictionary containing legacy key-value pairs where the values are of type `Any`.
  ///   - origin: collision source, defaults to `.fileLine()`.
  ///
  /// - Note:
  ///   - Each value is casted or converted to a compatible `ErrorInfoValueType` using the `_castOrConvertToCompatible` method.
  ///   - Collisions are resolved with the `.onDictionaryConsumption` source.
  ///
  /// Example:
  /// ```swift
  /// let legacyData: [String: Any] = ["errorCode": 404, "errorMessage": "Not Found"]
  ///
  /// let errorInfo = ErrorInfo(legacyUserInfo: legacyData)
  /// ```
  public init(legacyUserInfo: [String: Any],
              collisionSource origin: @autoclosure () -> CollisionSource.Origin = .fileLine()) {
    self.init()
    
    legacyUserInfo.forEach { key, value in
      let interpolatedValue = Self._castOrConvertToCompatible(legacyInfoValue: value)
      _storage.appendResolvingCollisions(key: key,
                                         value: _Record(_optional: .value(interpolatedValue), keyOrigin: .dynamic),
                                         insertIfEqual: true, // Swift.Dictionary<String, Any> has unique keys
                                         collisionSource: .onDictionaryConsumption(origin: origin()))
      // May be it is good to split into two separated dictionaries. Static initializer will return something like tuple of
      // (Self, nonSendableValues: [(key:, value:)])
    }
  }
}

extension ErrorInfo {
  internal static func _castOrConvertToCompatible(legacyInfoValue value: Any) -> any ErrorInfoValueType {
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
    //  case let value as [Any]: value.map(_castOrConvertToCompatible(legacyInfoValue:))
    //  case let value as [String: Any]: value.mapValues(_castOrConvertToCompatible(legacyInfoValue:))
    default: String(describing: value)
    }
  }
}
