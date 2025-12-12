//
//  CollisionResolvingResult.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 11/12/2025.
//

public struct KeyCollisionResolvingInput<Key: Hashable, Value, CId> {
  public let element: Element
  public let areValuesApproximatelyEqual: Bool
  public let donatorIndex: any (BinaryInteger & CustomStringConvertible)
  /// This can be `File + Line`, `Error domain + code` etc.
  public let identity: CId
  
  internal init(element: Element,
                areValuesApproximatelyEqual: Bool,
                donatorIndex: any BinaryInteger & CustomStringConvertible,
                identity: CId) {
    self.element = element
    self.areValuesApproximatelyEqual = areValuesApproximatelyEqual
    self.donatorIndex = donatorIndex
    self.identity = identity
  }
  
  public struct Element {
    public let key: Key
    public let existingValue: Value
    public let beingAddedValue: Value
    
    internal init(key: Key,
                  existingValue: Value,
                  beingAddedValue: Value) {
      self.key = key
      self.existingValue = existingValue
      self.beingAddedValue = beingAddedValue
    }
  }
}

public enum KeyCollisionResolvingResult<Key: Hashable> {
  case modifyDonatorKey(_ modifiedDonatorKey: Key)
  case modifyRecipientKey(_ modifiedRecipientKey: Key)
  case modifyBothKeys(donatorKey: Key, recipientKey: Key)
}

// public struct KeyCollisionResolve<D> where D: DictionaryUnifyingProtocol {
//  private let body: (_ donator: D.Element, _ recipient: D.Element) -> KeyCollisionResolvingResult
//
//  init(body: @Sendable @escaping (_: D.Element, _: D.Element) -> KeyCollisionResolvingResult) {
//    self.body = body
//  }
//
//  public func callAsFunction(donatorElement: D.Element, recipientElement: D.Element)
//    -> KeyCollisionResolvingResult {
//      body(donatorElement, recipientElement)
//  }
// }

// func res(res: KeyCollisionResolve<[String: Any]>) {
//  res(donatorElement: ("", 5), recipientElement: ("", ""))
// }

extension ErrorInfoMultipleValuesForKeyStrategy where Self: IterableErrorInfo, Key == String {
//  func asStringDict<I>(omitEqualValue: Bool,
//                       identity: I,
//                       resolve: (ResolvingInput<String, V, C>) -> ResolvingResult<String>) -> [String: String] {
//  }
  
//  @specialized(where Dict == DictionaryUnifyingProtocol<String, any ErrorInfoValueType>)
//  @specialized(where Key == String, Value == String, I == String)
//  @_specialize(where I == String, D == Dictionary<String, String>)
//  @_specialize(where Key == String, Value == String)
  /// Key-augmentation merge strategy.
  func asGenericDict<I, D>(
    omitEqualValue: Bool,
    collisionSource: I,
    randomGenerator: consuming some RandomNumberGenerator & Sendable = SystemRandomNumberGenerator(),
    resolve: (KeyCollisionResolvingInput<Key, Value, I>) -> KeyCollisionResolvingResult<Key>,
  ) -> D where D: DictionaryProtocol<Key, Value>, D: EmptyInitializableWithCapacityDictionary {
    var recipient = D(minimumCapacity: count)
    
    for keyValue in keyValuesView {
      Merge.DictUtils.withKeyAugmentationAdd(keyValue: keyValue,
                                             to: &recipient,
                                             donatorIndex: 0,
                                             omitEqualValue: omitEqualValue,
                                             identity: collisionSource,
                                             randomGenerator: &randomGenerator,
                                             resolve: resolve)
    }
    
    return recipient
  }
}
