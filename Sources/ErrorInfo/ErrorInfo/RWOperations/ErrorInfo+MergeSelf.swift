//
//  ErrorInfo+MergeSelf.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 06/10/2025.
//

// Improvement: reserve capacity

// MARK: - Instance methods

extension ErrorInfo {
  public mutating func merge(with firstDonator: Self,
                             _ otherDonators: Self...,
                             file: String = #fileID,
                             line: UInt = #line) {
    Self._mergeTo(recipient: &self, donator: firstDonator, origin: .fileLine(file: file, line: line))
    
    if otherDonators.isEmpty {
      return
    } else { // ~1% faster than `if !otherDonators.isEmpty { Self._mergeTo(...) }
      otherDonators.forEach {
        Self._mergeTo(recipient: &self, donator: $0, origin: .fileLine(file: file, line: line))
      }
    }
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
                             origin: @autoclosure () -> WriteProvenance.Origin) {
    Self._mergeTo(recipient: &self, donator: firstDonator, origin: origin())
    
    if otherDonators.isEmpty {
      return
    } else { // ~1% faster than `if !otherDonators.isEmpty { Self._mergeTo(...) }
      otherDonators.forEach {
        Self._mergeTo(recipient: &self, donator: $0, origin: origin())
      }
    }
  }
  
  public consuming func merged(with firstDonator: Self,
                               _ otherDonators: Self...,
                               file: String = #fileID,
                               line: UInt = #line) -> Self {
    Self._mergeTo(recipient: &self, donator: firstDonator, origin: .fileLine(file: file, line: line))
    
    if otherDonators.isEmpty {
      return self
    } else { // ~1% faster than `if !otherDonators.isEmpty { Self._mergeTo(...) }
      otherDonators.forEach {
        Self._mergeTo(recipient: &self, donator: $0, origin: .fileLine(file: file, line: line))
      }
      return self
    }
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
                               origin: @autoclosure () -> WriteProvenance.Origin) -> Self {
    Self._mergeTo(recipient: &self, donator: firstDonator, origin: origin())
    
    if otherDonators.isEmpty {
      return self
    } else { // ~1% faster than `if !otherDonators.isEmpty { Self._mergeTo(...) }
      otherDonators.forEach {
        Self._mergeTo(recipient: &self, donator: $0, origin: origin())
      }
      return self
    }
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
  public static func merged(_ recipient: consuming Self,
                            _ firstDonator: Self,
                            _ otherDonators: Self...,
                            file: String = #fileID,
                            line: UInt = #line) -> Self {
    _mergeTo(recipient: &recipient, donator: firstDonator, origin: .fileLine(file: file, line: line))
    
    if otherDonators.isEmpty {
      return recipient
    } else {
      otherDonators.forEach {
        Self._mergeTo(recipient: &recipient, donator: $0, origin: .fileLine(file: file, line: line))
      }
      return recipient
    }
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
                            origin: @autoclosure () -> WriteProvenance.Origin) -> Self {
    switch errorInfosArray.count {
    case 0: return .empty
    case 1: return errorInfosArray[0]
    default:
      errorInfosArray[1...].forEach {
        Self._mergeTo(recipient: &errorInfosArray[0], donator: $0, origin: origin())
      }
      return errorInfosArray[0]
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Generic IMP

extension ErrorInfo {
  private static func _mergeTo(recipient: inout Self,
                               donator: Self,
                               origin: @autoclosure () -> WriteProvenance.Origin) {
    for recordIndex in donator._storage.indices {
      // iteration over indices and access by index is faster than iteration over elements
      let (key, annotatedRecord) = donator._storage[recordIndex]
      recipient._storage.withCollisionAndDuplicateResolutionAdd(
        record: annotatedRecord.record,
        forKey: key,
        duplicatePolicy: .allowEqual,
        writeProvenance: annotatedRecord.collisionSource ?? .onMerge(origin: origin()),
      )
    }
  } // inlining has no performance gain
}
