//
//  ErrorInfo+LegacyErrorInfo.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

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
              valueInterpolation: @Sendable (Any) -> String = { prettyDescriptionOfOptional(any: $0) },
              collisionSource: @autoclosure () -> StringBasedCollisionSource.MergeOrigin = .fileLine()) {
    self.init()
    
    legacyUserInfo.forEach { key, value in
      let interpolatedValue = valueInterpolation(value)
      // Swift.Dictionary<String, Any> has unique keys with single value for key, so collision might never happen.
      // hardcode collisionSource: .onMerge(origin: .fileLine())
      _storage.appendResolvingCollisions(key: key,
                                         value: interpolatedValue,
                                         insertIfEqual: true,
                                         collisionSource: .onDictionaryConsumption(origin: collisionSource()))
      // TODO: ? insteaad of converting to string may be try cast to concrete standard types, and iterpolate if only cast fails
      // the list of types can be quite large and such conditional cast can be slow, but there is no way ta cast dynamically
      // as `any ErrorInfoValueType` becuase Senadble is a marker protocol.
      // Another questions is NSObject, AnyObject and actor instances (with #if canImport(Foundation)).
      // May be it is good to split into two separated dictionaries. Static initializer will return something likr tuple of
      // (Self, nonSendableValues:)
    }
  }
}
