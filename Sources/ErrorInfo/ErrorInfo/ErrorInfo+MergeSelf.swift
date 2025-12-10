//
//  ErrorInfo+MergeSelf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

// Improvement: minimize CoW / allocations

// MARK: - Instance methods

extension ErrorInfo {
  /// Merges the current `ErrorInfo` instance with one or more other `ErrorInfo` instances.
  /// Duplicate values within each `ErrorInfo` are retained.
  ///
  /// - Parameters:
  ///   - firstDonator: The first `ErrorInfo` instance to merge.
  ///   - otherDonators: Additional `ErrorInfo` instances to merge.
  ///   - mergeOrigin: The source of the merge (defaults to `.fileLine()`).
  ///
  /// # Example:
  /// ```swift
  /// var info1: ErrorInfo = [.errorCode: 404]
  /// let info2: ErrorInfo = [.errorMessage: "Not Found"]
  ///
  /// info1.merge(with: info2)
  /// // info1 now contains both errorCode and errorMessage.
  /// ```
  public mutating func merge(with firstDonator: Self,
                             _ otherDonators: Self...,
                             collisionSource mergeOrigin: CollisionSource.Origin = .fileLine()) {
    self = Self._merged(recipient: self,
                        donators: [firstDonator] + otherDonators,
                        collisionSource: mergeOrigin)
  }
  
  /// Returns a new `ErrorInfo` instance by merging the current instance with one or more others.
  /// Duplicate values within each `ErrorInfo` are retained.
  ///
  /// - Parameters:
  ///   - firstDonator: The first `ErrorInfo` instance to merge.
  ///   - otherDonators: Additional `ErrorInfo` instances to merge.
  ///   - mergeOrigin: The source of the merge (defaults to `.fileLine()`).
  ///
  /// # Example:
  /// ```swift
  /// let info1: ErrorInfo = [.errorCode: 404]
  /// let info2: ErrorInfo = [.errorMessage: "Not Found"]
  ///
  /// let mergedInfo = info1.merged(with: info2)
  /// // mergedInfo now contains both errorCode and errorMessage.
  /// ```
  public consuming func merged(with firstDonator: Self,
                               _ otherDonators: Self...,
                               collisionSource mergeOrigin: CollisionSource.Origin = .fileLine()) -> Self {
    Self._merged(recipient: self,
                 donators: [firstDonator] + otherDonators,
                 collisionSource: mergeOrigin)
  }
}

// MARK: - Static funcs

extension ErrorInfo {
  /// Merges a recipient `ErrorInfo` with one or more `ErrorInfo` donators and returns a new instance.
  /// Duplicate values within each `ErrorInfo` are retained.
  ///
  /// - Parameters:
  ///   - recipient: The recipient `ErrorInfo` instance to merge into.
  ///   - firstDonator: The first `ErrorInfo` donator to merge.
  ///   - otherDonators: Additional `ErrorInfo` donators to merge.
  ///   - mergeOrigin: The source of the merge (defaults to `.fileLine()`).
  ///
  /// - Returns: A new `ErrorInfo` instance containing the merged data.
  ///
  /// # Example:
  /// ```swift
  /// let info1: ErrorInfo = [.errorCode: 404]
  /// let info2: ErrorInfo = [.errorMessage: "Not Found"]
  ///
  /// let mergedInfo: ErrorInfo = .merged(info1, info2)
  /// // mergedInfo now contains both errorCode and errorMessage.
  /// ```
  public static func merged(_ recipient: Self,
                            _ firstDonator: Self,
                            _ otherDonators: Self...,
                            collisionSource mergeOrigin: CollisionSource.Origin = .fileLine()) -> Self {
    _merged(recipient: recipient,
            donators: [firstDonator] + otherDonators,
            collisionSource: mergeOrigin)
  }
  
  /// Merges multiple `ErrorInfo` instances from an array and returns the resulting merged instance.
  ///
  /// - Parameters:
  ///   - errorInfosArray: An array of `ErrorInfo` instances to merge.
  ///   - mergeOrigin: The source of the merge (defaults to `.fileLine()`).
  ///
  /// - Returns: A new `ErrorInfo` instance containing the merged data.
  ///
  /// - Example:
  /// ```swift
  /// let info1: ErrorInfo = ["errorCode": 404]
  /// let info2: ErrorInfo = ["errorMessage": "Not Found"]
  /// let mergedInfo = ErrorInfo.merged(errorInfosArray: [info1, info2])
  /// // mergedInfo contains both errorCode and errorMessage.
  /// ```
  public static func merged(errorInfosArray: consuming [Self],
                            collisionSource mergeOrigin: CollisionSource.Origin = .fileLine()) -> Self {
    switch errorInfosArray.count {
    case 0: return .empty
    case 1: return errorInfosArray[0]
    default: return _merged(recipient: errorInfosArray[0], donators: errorInfosArray[1...], collisionSource: mergeOrigin)
    }
  }
  
  // Here keeping equal values has 2 variants:
  // 1. keep duplicates for inside of each info, but deny duplucates between them
  // 2. remove duplicates from everywhere, finally on value is kept
  // 3. keep duplicates, if any
  
  // 3d variant seems the most reasonable.
  // If there are 2 equal values in an ErrorInfo, someone explicitly added it. If so, these 2 instances should not be
  // deduplicated by default making a merge.
  // If there 2 equal values across several ErrorInfo & there is no collision of values inside errorinfo, then
  // the should caan be deduplicated by an option(func arg).
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Generic IMP

extension ErrorInfo {
  /// This internal generic method performs the merging operation by iterating over the donators.
  internal static func _merged(recipient: consuming Self,
                               donators: some RandomAccessCollection<Self>,
                               collisionSource mergeOrigin: CollisionSource.Origin) -> Self {
    // Improvement: reserve capacity
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
