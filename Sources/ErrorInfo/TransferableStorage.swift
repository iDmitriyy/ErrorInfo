//
//  TransferableStorage.swift
//  ErrorInfo
//
//  Created by tmp on 27/09/2025.
//

import struct Synchronization.Mutex
private import struct OrderedCollections.OrderedDictionary

// WIP, research

/// Only single value for a key.
/// No collsions resolution, value overwritten.
internal struct TransferableStorage<Key: Hashable & Sendable> {
  /// If enclosing instance is copied, then TransferableStorage is shared between copies.
  /// Only one of all copies is able to extract values from TransferableStorage, which is unintuitive.
  private var _storage: Storage?
  
  private var mutStorage: Storage {
    mutating get {
      if let storageInstance = _storage {
        return storageInstance
      } else {
        let storageInstance = Storage()
        _storage = storageInstance
        return storageInstance
      }
    }
  }
  
  init() {}
  
  /// effectively `Any`
  mutating func putOnceExtractableCopyableNonSendable<T>(_ nonSendable: sending T, forKey key: Key) {
    let nonSendable = Mutex(nonSendable) // ! wrap
    mutStorage.mutex.withLock { dict in
      dict[key] = .copyableNonSendable(instance: nonSendable.withLock { $0 })
    }
  }
  
  // mutating func sendNonCopyableNonSendable<T: ~Copyable>(_ nonCopyable: consuming sending T) {}
  
  mutating func extractOnce<T>(forKey key: Key) -> sending T? {
    mutStorage.mutex.withLock { dict -> T? in
      switch dict[key] {
      case .copyableNonSendable(let instance): instance as? T
      case .none: nil
      }
    }
  }
  
  class NonSendable {
    var foo: Int = 0
  }
}

extension TransferableStorage {
  enum ValueVariant {
    // case nonCopyableNonSendable(any ~Copyable) // not possible yet
    case copyableNonSendable(instance: Any)
  }
  
  private final class Storage {
    let mutex: Mutex<OrderedDictionary<Key, ValueVariant>>
    
    init() {
      mutex = Mutex([:])
    }
  }
}
