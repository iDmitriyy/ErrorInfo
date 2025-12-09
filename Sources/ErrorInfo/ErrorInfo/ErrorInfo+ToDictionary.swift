//
//  ErrorInfo+ToDictionary.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 10/10/2025.
//

extension ErrorInfo {
  // collapseNilInstances: Bool = false
  public func asStringDict(collisionSourceInterpolation: (CollisionSource) -> String = { $0.defaultStringInterpolation() })
    -> [String: String] { // TODO: should be a protocol default imp
    var dict = [String: String](minimumCapacity: _storage.count)
    _storage.forEach { key, wrappedValue in // TODO: use builtin initializer of OrderedDict instead of foreach
      // TODO: use prefix / suffix transforms for augmenting keys
      let effectiveKey: String = if let collisionSource = wrappedValue.collisionSource {
        key + collisionSourceInterpolation(collisionSource)
      } else {
        key
      }
      // FIXME: use `withKeyAugmentationAdd(...)`
      dict[effectiveKey] = String(describing: wrappedValue.value)
    }
    return dict
  }
  
  public func asDictionary<V>() -> [String: V] {
    [:]
  }
  
  // TODO: ordered json  of asEncodableDictionary
  
  public func asEncodableDictionary() -> OrderedEncodableDictionary {
    // proof of concept for now
    
    // TODO: - proper implementation
    // nil options
    // keyOrigin, collision, prefix
    
    let valueTransform: (CollisionTaggedValue<ErrorInfo._Entry, CollisionSource>) -> AnyEncodableSingleValue = { taggedValue in
      switch taggedValue.value.optional.optionalValue {
      case .some(let sendableValueExistential):
        if let anyEncodableSendable = __conditionalCast(sendableValueExistential, to: (any Encodable & Sendable).self) {
          // TODO: - need to make proper AnyEncodable, not only for primitives.
          return AnyEncodableSingleValue(anyEncodableSendable)
        } else {
          return AnyEncodableSingleValue(String(describing: sendableValueExistential))
        }
      case .none:
        return AnyEncodableSingleValue("nil") // TODO: - nil as object
      }
    }
    
    let orderedDict = Merge
      .summaryInfo(infoSources: [self],
                   infoKeyPath: \._storage,
                   elementKeyStringPath: \.self,
                   keyOriginAvailability: .notAvailable,
                   collisionAvailability: .notAvailable,
                   keysPrefixOption: .noPrefix,
                   annotationsFormat: .default,
                   randomGenerator: SystemRandomNumberGenerator(),
                   infoSourceSignatureBuilder: { _ in "" },
                   valueTransform: valueTransform)
        
    return OrderedEncodableDictionary(wrapped: orderedDict)
  }
}

private import struct OrderedCollections.OrderedDictionary

/// 
public struct OrderedEncodableDictionary: Encodable {
  private let wrapped: OrderedDictionary<String, AnyEncodableSingleValue>
  
  internal init(wrapped: OrderedDictionary<String, AnyEncodableSingleValue>) {
    self.wrapped = wrapped
  }
  
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: DictionaryCodingKey.self)
    for (key, value) in wrapped {
      let codingKey = DictionaryCodingKey(stringValue: key)
      try container.encode(value, forKey: codingKey)
    }
  }
  
  // public init(from decoder: Decoder) throws {
  //   var dict = wrapped = OrderedDictionary<String, AnySendableEncodable>()
  //
  //   let container = try decoder.container(keyedBy: DictionaryCodingKey.self)
  //   for key in container.allKeys {
  //     let value = try container.decode(Value.self, forKey: key)
  //     self[key.stringValue as! Key] = value
  //   }
  // }
}
