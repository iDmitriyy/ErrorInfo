//
//  TransferableStorage.swift
//  ErrorInfo
//
//  Created by tmp on 27/09/2025.
//

import struct Synchronization.Mutex
private import struct OrderedCollections.OrderedDictionary

// WIP, research
// prototype

/// Only single value for a key.
/// No collsions resolution, value overwritten.
internal struct TransferableStorage<Key: Hashable & Sendable>: Sendable {
  // If enclosing instance is copied, then TransferableStorage is shared between copies.
  // Only one of all copies is able to extract values from TransferableStorage, which is unintuitive.
  // It is possible to allow extraction of NonSendable values multiple timesb but it is unsafe and might need to be wrapped
  // by some synchr.
  // For ~Copyable instances miltiple extraction is not possible at all, so there would be an assymetry with NonSendable.
  
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
  
  // mutating func putNonCopyableNonSendable<T: ~Copyable>(_ nonCopyable: consuming sending T) {}
  
  mutating func extractOnce<T>(forKey key: Key) -> sending T? {
    mutStorage.mutex.withLock { dict -> T? in
      defer { dict[key] = nil }
      
      return switch dict[key] {
      case .copyableNonSendable(let instance): instance as? T
      case .anyObjectNonSendable(let instance): instance as? T
      case .anyActor(let instance): instance as? T
      case .none: nil
      }
    }
  }
}

extension TransferableStorage {
  enum ValueVariant {
    case copyableNonSendable(instance: Any)
    case anyObjectNonSendable(instance: AnyObject)
    case anyActor(instance: any Actor)
  }
  
  private final class Storage: Sendable {
    let mutex: Mutex<OrderedDictionary<Key, ValueVariant>>
    
    init() {
      mutex = Mutex([:])
    }
  }
}
