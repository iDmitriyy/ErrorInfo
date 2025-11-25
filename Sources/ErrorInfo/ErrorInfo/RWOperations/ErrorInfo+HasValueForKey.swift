//
//  ErrorInfo+HasValueForKey.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 25/11/2025.
//

// MARK: HasValues ForKey

extension ErrorInfo {
  public struct KeyValueLookupResult: OptionSet, Sendable {
    public var rawValue: UInt8
    
    public init(rawValue: UInt8) {
      self.rawValue = rawValue
    }
    
    static let nothing = Self([])
    
    static let value = Self(rawValue: 1 << 0)
    
//    static let multipleValues = Self(rawValue: 1 << 1)
    
    static let nilInstance = Self(rawValue: 1 << 2)
    
//    static let multipleNilInstances = Self(rawValue: 1 << 3)
    
    static let valueAndNil = Self(rawValue: 1 << 4)
  }
  
  // public func keyValueLookupResult() -> KeyValueLookupResult {}
  
  public func hasValues(forKey key: ErronInfoLiteralKey) -> Bool {
    _storage.hasValue(forKey: key.rawValue)
  }
  
  @_disfavoredOverload
  public func hasValues(forKey key: Key) -> Bool {
    _storage.hasValue(forKey: key)
  }
  
  // public func hasCollisions() -> Bool {
  //   _storage.contains // not use Sequence.contains, check perfomace of `contains` in multivaluesdict type
  // }
  
  // func hasCollisions(forKey key: ErronInfoLiteralKey) -> Bool {}
  
  // @_disfavoredOverload
  // func hasCollisions(forKey key: Key) -> Bool {}
}

// MARK: HasNonNilValues ForKey

// TODO: implement
// extension ErrorInfo {
//  public func hasNonNilValues(forKey key: ErronInfoLiteralKey) -> Bool {
//    hasNonNilValues(forKey: key.rawValue)
//  }
//
//  public func hasNonNilValues(forKey key: Key) -> Bool {
//
//  }
// }
