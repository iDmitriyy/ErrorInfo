//
//  ErrorInfo+LegacyErrorInfo.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

import Foundation

// MARK: - Init with [String: Any]

extension ErrorInfo {
  /// Initializes an `ErrorInfo` instance using a legacy `[String: Any]` user info dictionary.
  ///
  /// This initializer takes a `[String: Any]` dictionary, processes each key-value pair,
  /// and converts the values to a compatible type.
  ///
  /// - Parameters:
  ///   - legacyUserInfo: A dictionary containing legacy key-value pairs where the values are of type `Any`.
  ///   - origin: origin for collisions, defaults to `.fileLine()`.
  ///
  /// - Note:
  ///   - Each value is casted or converted to a compatible `ErrorInfoValueType` using the `_castOrConvertToCompatible` method.
  ///   - Collisions are resolved with the `.onDictionaryConsumption` source.
  ///
  /// # Example:
  /// ```swift
  /// let legacyData: [String: Any] = ["errorCode": 404, "errorMessage": "Not Found"]
  ///
  /// let errorInfo = ErrorInfo(legacyUserInfo: legacyData)
  /// ```
  public init(legacyUserInfo: [String: Any],
              origin collisionOrigin: @autoclosure () -> WriteProvenance.Origin) {
    self.init(minimumCapacity: legacyUserInfo.count)
    _appendLegacyUserInfoImp(legacyUserInfo: legacyUserInfo, origin: collisionOrigin())
  }
  
  public mutating func append(legacyUserInfo: [String: Any],
                              origin: @autoclosure () -> WriteProvenance.Origin) {
    _appendLegacyUserInfoImp(legacyUserInfo: legacyUserInfo, origin: origin())
  }
}

extension ErrorInfo {
  // TODO: - add convenience Error consuming API
  private mutating func _appendLegacyUserInfoImp(legacyUserInfo: [String: Any],
                                                 origin: @autoclosure () -> WriteProvenance.Origin) {
    legacyUserInfo.forEach { key, value in
      let compatibleValue = Self._castOrConvertToCompatible(legacyInfoValue: value)
      let record = BackingStorage.Record(keyOrigin: .fromCollection, someValue: .value(compatibleValue))
      _storage._addRecordWithCollisionAndDuplicateResolution(
        record,
        fromAppendingScope: .detached,
        forKey: key,
        duplicatePolicy: .allowEqual, // no effect here, Swift.Dictionary has unique keys
        writeProvenance: .onDictionaryConsumption(origin: origin()),
      )
      // TBD: May be it is good to split into two separated dictionaries. Static initializer will return something like tuple of
      // (Self, nonSendableValues: [(key:, value:)])
    }
  }
  
  private static func _castOrConvertToCompatible(legacyInfoValue: Any) -> ValueExistential {
    // For typical NSError, String value is most often used for a key, in general. Then NSNumber, URL, [String], [Any],
    // [String: Any].
    // So sort the switch this way to minimize casting overhead.
    
    let converted: ValueExistential = switch ErrorInfoFuncs.flattenOptional(any: legacyInfoValue) {
    case .value(let unwrappedAnyValue):
      switch unwrappedAnyValue {
      case let castedValue as String: castedValue
      case let castedValue as Bool: castedValue
      case let castedValue as Int: castedValue
      case let castedValue as UInt: castedValue
      case let castedValue as Double: castedValue
      case let castedValue as Float: castedValue
      case let castedValue as [String]: castedValue
      case let castedValue as [String: String]: castedValue
      // DEFERRED:
      //  case let value as [Any]: value.map(_castOrConvertToCompatible(legacyInfoValue:))
      //  case let value as [String: Any]: value.mapValues(_castOrConvertToCompatible(legacyInfoValue:))
      #if canImport(Foundation)
        case let castedValue as URL: castedValue
        case let castedValue as Date: castedValue
      #endif
      case let castedValue as Int64: castedValue
      case let castedValue as Int32: castedValue
      case let castedValue as Int16: castedValue
      case let castedValue as Int8: castedValue
      case let castedValue as UInt64: castedValue
      case let castedValue as UInt32: castedValue
      case let castedValue as UInt16: castedValue
      case let castedValue as UInt8: castedValue
      default: String(describing: unwrappedAnyValue)
      }
      
    case .nilInstance(let typeOfWrapped):
      ErrorInfoFuncs.nilString(typeOfWrapped: typeOfWrapped)
    }
    
    return converted
  } // @inlining has no benefits for this func
}
