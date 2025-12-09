//
//  ErrorInfo+MergeSelf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

extension ErrorInfo {
  // Here keeping equal values has 2 variants:
  // 1. keep duplicates for inside of each info, but deny duplucates between them
  // 2. remove duplicates from everywhere, finally on value is kept
  // 3. keep duplicates, if any
  
  // 3d variant seems the most reasonable.
  // If there are 2 equal values in an ErrorInfo, someone explicitly added it. If so, these 2 instances should not be
  // deduplicated by default making a merge.
  // If there 2 equal values across several ErrorInfo & there is no collision of values inside errorinfo, then
  // the should caan be deduplicated by an option(func arg).
  
  // Improvement: minimize CoW
  
  // MARK: Instance mutating methods
  
  public mutating func merge(with firstDonator: Self,
                             _ otherDonators: Self...,
                             collisionSource mergeOrigin: CollisionSource.Origin = .fileLine()) {
    self = Self._merged(recipient: self,
                        donators: [firstDonator] + otherDonators,
                        collisionSource: mergeOrigin)
  }
  
  // MARK: Static funcs
  
  public static func merged(_ recipient: Self,
                            _ firstDonator: Self,
                            _ otherDonators: [Self],
                            collisionSource mergeOrigin: CollisionSource.Origin = .fileLine()) -> Self {
    _merged(recipient: recipient,
            donators: [firstDonator] + otherDonators,
            collisionSource: mergeOrigin)
  }
}

extension ErrorInfo {
  internal static func _merged(recipient: consuming Self, // TODO: consuming?
                               donators: [Self],
                               collisionSource mergeOrigin: CollisionSource.Origin) -> Self {
    // TODO: reserve capacity
    for donator in donators {
      for (key, valueWrapper) in donator._storage {
        recipient._storage
          .appendResolvingCollisions(key: key,
                                     value: valueWrapper.value,
                                     insertIfEqual: true,
                                     collisionSource: valueWrapper.collisionSource ?? .onMerge(origin: mergeOrigin))
        // TODO: should collizion source be composite / indirect?
        // Keep the most simple variant for now
        // ["a": 1] merge with ["a": 1, a: "1"(collision#1)]
        // result: ["a": 1, a: "1"(collision#2), a: "1"(collision#1)]
      }
    }
    return recipient
  }
}
