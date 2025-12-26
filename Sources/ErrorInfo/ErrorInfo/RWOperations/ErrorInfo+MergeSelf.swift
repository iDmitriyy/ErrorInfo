//
//  ErrorInfo+MergeSelf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

// Improvement: minimize CoW / allocations

// MARK: - Instance methods

extension ErrorInfo {
  public mutating func merge(with firstDonator: Self,
                             _ otherDonators: Self...,
                             file: StaticString = #fileID,
                             line: UInt = #line) {
    self = Self._mergedImp(recipient: self,
                           donators: [firstDonator] + otherDonators,
                           origin: .fileLine(file: file, line: line))
  }
  
  /// Merges the current `ErrorInfo` instance with one or more other `ErrorInfo` instances.
  /// Merge preserve all information by design (duplicatePolicy `allowEqual` used internally).
  /// Duplicate and `nil` values are preserved, collision source annotations are added as is.
  ///
  /// - Parameters:
  ///   - firstDonator: The first `ErrorInfo` instance to merge.
  ///   - otherDonators: Additional `ErrorInfo` instances to merge, optional parameter.
  ///   - origin: The source of the merge (defaults to `.fileLine()`).
  ///
  /// # Example:
  /// ```swift
  /// let info: ErrorInfo = [
  ///   .maxItemsPerPage: 20,
  ///   .itemsLoaded: 21
  /// ]
  ///
  /// let cacheState: ErrorInfo = [
  ///   .cacheSizeLimit: 1000,
  ///   .cacheSizeUsed: 1000,
  /// ]
  ///
  /// info.merge(with: cacheState)
  /// ```
  public mutating func merge(with firstDonator: Self,
                             _ otherDonators: Self...,
                             origin: WriteProvenance.Origin) {
    self = Self._mergedImp(recipient: self,
                           donators: [firstDonator] + otherDonators,
                           origin: origin)
  }
  
  public consuming func merged(with firstDonator: Self,
                               _ otherDonators: Self...,
                               file: StaticString = #fileID,
                               line: UInt = #line) -> Self {
    Self._mergedImp(recipient: self,
                    donators: [firstDonator] + otherDonators,
                    origin: .fileLine(file: file, line: line))
  }
  
  /// Returns a new `ErrorInfo` instance by merging the current instance with one or more others.
  /// Merge preserve duplicates by design (duplicatePolicy `allowEqual` used internally).
  ///
  /// - Parameters:
  ///   - firstDonator: The first `ErrorInfo` instance to merge.
  ///   - otherDonators: Additional `ErrorInfo` instances to merge, optional parameter.
  ///   - origin: The source of the merge (defaults to `.fileLine()`).
  ///
  /// # Example:
  /// ```swift
  /// let info: ErrorInfo = [
  ///   .maxItemsPerPage: 20,
  ///   .itemsLoaded: 21
  /// ]
  ///
  /// let cacheState: ErrorInfo = [
  ///   .cacheSizeLimit: 1000,
  ///   .cacheSizeUsed: 1000,
  /// ]
  ///
  /// let error = AppError(info: info.merged(with: cacheState))
  /// ```
  public consuming func merged(with firstDonator: Self,
                               _ otherDonators: Self...,
                               origin: WriteProvenance.Origin) -> Self {
    Self._mergedImp(recipient: self,
                    donators: [firstDonator] + otherDonators,
                    origin: origin)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Static funcs

extension ErrorInfo {
  /// Merges a recipient `ErrorInfo` with one or more `ErrorInfo` donators and returns a new instance.
  /// Merge preserve duplicates by design (duplicatePolicy `allowEqual` used internally).
  ///
  /// - Parameters:
  ///   - recipient: The recipient `ErrorInfo` instance to merge into.
  ///   - firstDonator: The first `ErrorInfo`instance to merge.
  ///   - otherDonators: Additional `ErrorInfo` instances to merge, optional parameter.
  ///   - mergeOrigin: The source of the merge (defaults to `.fileLine()`).
  ///
  /// - Returns: A new `ErrorInfo` instance containing the merged data.
  ///
  /// # Example:
  /// ```swift
  /// let info: ErrorInfo = [
  ///   .maxItemsPerPage: 20,
  ///   .itemsLoaded: 21
  /// ]
  ///
  /// let cacheState: ErrorInfo = [
  ///   .cacheSizeLimit: 1000,
  ///   .cacheSizeUsed: 1000,
  /// ]
  ///
  /// let error = AppError(info: .merged(info, cacheState))
  /// ```
  public static func merged(_ recipient: Self,
                            _ firstDonator: Self,
                            _ otherDonators: Self...,
                            file: StaticString = #fileID,
                            line: UInt = #line) -> Self {
    _mergedImp(recipient: recipient,
               donators: [firstDonator] + otherDonators,
               origin: .fileLine(file: file, line: line))
  }
  
  /// Merges multiple `ErrorInfo` instances from an array and returns the resulting merged instance.
  /// Merge preserve duplicates by design (duplicatePolicy `allowEqual` used internally).
  ///
  /// - Parameters:
  ///   - errorInfosArray: An array of `ErrorInfo` instances to merge.
  ///   - origin: The source of the merge.
  ///
  /// - Returns: A new `ErrorInfo` instance containing the merged data.
  ///
  /// # Example:
  /// ```swift
  /// let info: ErrorInfo = [
  ///   .maxItemsPerPage: 20,
  ///   .itemsLoaded: 21
  /// ]
  ///
  /// let cacheState: ErrorInfo = [
  ///   .cacheSizeLimit: 1000,
  ///   .cacheSizeUsed: 1000,
  /// ]
  ///
  /// let mergedInfo = ErrorInfo.merged(errorInfosArray: [info, cacheState])
  /// ```
  public static func merged(errorInfosArray: consuming [Self],
                            origin: WriteProvenance.Origin) -> Self {
    switch errorInfosArray.count {
    case 0: return .empty
    case 1: return errorInfosArray[0]
    default: return _mergedImp(recipient: errorInfosArray[0], donators: errorInfosArray[1...], origin: origin)
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
  internal static func _mergedImp(recipient: consuming Self,
                                  donators: some RandomAccessCollection<Self>,
                                  origin: WriteProvenance.Origin) -> Self {
    // Improvement: reserve capacity
    for donator in donators {
      for (key, annotatedRecord) in donator._storage {
        recipient._storage._addRecordWithCollisionAndDuplicateResolution(
          annotatedRecord.record,
          fromAppendingScope: .detached,
          forKey: key,
          duplicatePolicy: .allowEqual,
          writeProvenance: annotatedRecord.collisionSource ?? .onMerge(origin: origin),
        )
      }
    }
    return recipient
  }
}
