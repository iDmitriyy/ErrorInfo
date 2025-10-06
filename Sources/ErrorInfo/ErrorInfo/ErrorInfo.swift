//
//  ErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 14.12.2024.
//

import struct OrderedCollections.OrderedDictionary

// TODO: - add tests for elements ordering stability
// TODO: - add overloads for Sendable AnyObjects & actors

public struct ErrorInfo: Sendable { // ErrorInfoCollection
  public typealias ValueType = ErrorInfoValueType
  public static let empty: Self = Self()
  
  internal typealias BackingStorage = OrderedMultiValueErrorInfoGeneric<String, any ValueType>
  
  // FIXME: private(set)
  internal var _storage: BackingStorage
  
  fileprivate init(storage: BackingStorage) {
    self._storage = storage
  }
  
  public init() {
    self.init(storage: BackingStorage())
  }
  
  // init(name: String, dict: OrderedMultipleValuesDictionaryLiteral)
}

// MARK: CustomStringConvertible IMP

extension ErrorInfo {
  public var description: String { String(describing: _storage) }
  // FIXME: use @DebugDescription macro
  public var debugDescription: String { String(reflecting: _storage) }
}

// MARK: Get / Set

extension ErrorInfo {
  #warning("comment")
//  public mutating func add(key: String, anyValue: Any, line: UInt = #line) {
//    // use cases:
//    // взятие по ключу значения из [String: Any]. Если оно nil, то Тип мы и не узнаем. Если не nil, может быть полезно
//    // id instance из ObjC
//    // >> нужны доработки, т.к. реальный Тип значения получить удается не всегда
//    var typeDescr: String { " (T.Type=" + "\(type(of: anyValue))" + ") " }
//    _addValue(typeDescr + prettyDescription(any: anyValue), forKey: key, line: line)
//  }
  
  public subscript(_: Key) -> (Value)? {
    get { fatalError() }
    set(maybeValue) {}
  }
  
  func _getUnderlyingValue(forKey _: Key) -> (any ValueType)? {
    nil
  }
  
  mutating func _addResolvingCollisions(key: Key, value: any ValueType, omitEqualValue: Bool) {
    // Here values are added by ErrorInfo subscript, so use subroutine of root merge-function to put value into storage, which
    // adds a random suffix if collision occurs
    // Pass unmodified key
    // shouldOmitEqualValue = true, in ccomparison to addKeyPrefix function.
//    ErrorInfoDictFuncs.Merge
//      ._putResolvingWithRandomSuffix(value,
//                                     assumeModifiedKey: key,
//                                     shouldOmitEqualValue: true, // TODO: explain why
//                                     suffixFirstChar: ErrorInfoMerge.suffixBeginningForSubcriptScalar,
//                                     to: &_storage)
    _storage.appendResolvingCollisions(key: key,
                                       value: value,
                                       omitEqualValue: omitEqualValue,
                                       collisionSource: .onSubscript)
  }
}

// MARK: Prefix & Suffix

extension ErrorInfo {
  public mutating func addKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc) {
//    ErrorInfoDictFuncs.addKeyPrefix(keyPrefix,
//                                    toKeysOf: &_storage,
//                                    transform: transform)
  }
  
  public consuming func addingKeyPrefix(_ keyPrefix: String, transform: PrefixTransformFunc) -> Self {
    addKeyPrefix(keyPrefix, transform: transform)
    return self
  }
}

// MARK: Merge

extension ErrorInfo {
  public mutating func merge<each D>(_: repeat each D,
                                     collisionSource: @autoclosure () -> StringBasedCollisionSource.MergeOrigin = .fileLine())
    where repeat each D: ErrorInfoCollection {
      fatalError()
//    ErrorInfoDictFuncs.Merge._mergeErrorInfo
    }
  
  public consuming func merging<each D>(_ donators: repeat each D,
                                        collisionSource _: @autoclosure () -> StringBasedCollisionSource.MergeOrigin = .fileLine())
    -> Self where repeat each D: ErrorInfoCollection {
      merge(repeat each donators)
      return self
    }
}

// extension ErrorInfo {
//  // TODO: - merge method with consuming generics instead of variadic ...
//
//  public static func merge(_ otherInfos: Self..., to errorInfo: inout Self, line: UInt = #line) {
//    ErrorInfoFuncs._mergeErrorInfo(&errorInfo.storage, with: otherInfos.map { $0.storage }, line: line)
//  }
//
//  public static func merge(_ otherInfo: Self,
//                           to errorInfo: inout Self,
//                           addingKeyPrefix keyPrefix: String,
//                           uppercasingFirstLetter uppercasing: Bool = true,
//                           line: UInt = #line) {
//    ErrorInfoFuncs.mergeErrorInfo(otherInfo.storage,
//                                      to: &errorInfo.storage,
//                                      addingKeyPrefix: keyPrefix,
//                                      uppercasingFirstLetter: uppercasing,
//                                      line: line)
//  }
//
//  public static func merged(_ errorInfo: Self, _ otherInfos: Self..., line: UInt = #line) -> Self {
//    var errorInfoRaw = errorInfo.storage
//    ErrorInfoFuncs._mergeErrorInfo(&errorInfoRaw, with: otherInfos.map { $0.storage }, line: line)
//    return Self(storage: errorInfoRaw)
//  }
// }

// MARK: collect values from KeyPath

extension ErrorInfo {
  // public static func fromKeys<T, each V: ErrorInfo.ValueType>(of instance: T,
  @inlinable
  public static func collect<R, each V: ErrorInfo.ValueType>(from instance: R,
                                                             addTypePrefix: Bool,
                                                             keys key: repeat KeyPath<R, each V>) -> Self {
    func collectEach(_ keyPath: KeyPath<R, some ErrorInfo.ValueType>, root: R, to info: inout Self) {
      var keyPathString = ErrorInfoFuncs.asErrorInfoKeyString(keyPath: keyPath)
      if addTypePrefix {
        keyPathString = "\(type(of: root))." + keyPathString
      }
      // TODO: if keyPathString can not be formed correctly then macro can be tried
      info[keyPathString] = root[keyPath: keyPath]
    }
    // ⚠️ @iDmitriyy
    // TODO: - add tests
    var info = Self()
    
    repeat collectEach(each key, root: instance, to: &info)
    
    return info
  }
}
