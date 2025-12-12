//
//  LegacyErrorInfo.swift
//  swifty-kit
//
//  Created by Dmitriy Ignatyev on 16/09/2025.
//

// ?? can It be done as typeaalias
// LegacyErrorInfo = GenericValueErrorInfo<String, Any>

/// Add partial functionality of collisions resolution to dictionary
struct DictionaryErrorInfoOverlay<Dict> { // – it is the same as LegacyErrorInfo. Can generically be done.
  private(set) var dictionary: Dict
}

public struct LegacyErrorInfo: IterableErrorInfo {
  public typealias Key = String
  public typealias Value = Any
  public typealias Element = (key: String, value: Any)
  
  private var _storage: KeyAugmentationErrorInfoGeneric<Dictionary<String, Any>>
  
  public var isEmpty: Bool { _storage.isEmpty }
  
  public var count: Int { _storage.count }
  
  public func makeIterator() -> some IteratorProtocol<Element> {
    _storage.makeIterator()
  }
  
  public init(_ info: [String: Any]) {
    _storage = KeyAugmentationErrorInfoGeneric(info)
  }
}

extension LegacyErrorInfo {
  // TODO: this method should be an overload for default implementation
  public func asDictionary() -> [String: Any] {
    _storage._storage
  }
}

// extension LegacyErrorInfo: ExpressibleByDictionaryLiteral {}

extension LegacyErrorInfo {
  // public subscript(_: Key) -> (Value)? {}
  
  func addPrefix() {}
  
  mutating func merge() {}
  
//  mutating func _addResolvingCollisions(key: Key, value: any ValueType, omitEqualValue: Bool) {
//    // Here values are added by ErrorInfo subscript, so use subroutine of root merge-function to put value into storage, which
//    // adds a random suffix if collision occurs
//    // Pass unmodified key
//    // shouldOmitEqualValue = true, in ccomparison to addKeyPrefix function.
//    //    ErrorInfoDictFuncs.Merge
//    //      ._putResolvingWithRandomSuffix(value,
//    //                                     assumeModifiedKey: key,
//    //                                     shouldOmitEqualValue: true, // TODO: explain why
//    //                                     suffixFirstChar: ErrorInfoMerge.suffixBeginningForSubcriptScalar,
//    //                                     to: &_storage)
//  }
}

