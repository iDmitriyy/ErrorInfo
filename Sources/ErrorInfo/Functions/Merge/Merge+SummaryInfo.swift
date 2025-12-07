//
//  Error+Merge2.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 03/10/2025.
//

private import SwiftyKit
private import Algorithms
import protocol InternalCollectionsUtilities._UniqueCollection

import Foundation

/// Add partial functionality of collisions resolution to dictionary
struct DictionaryErrorInfoOverlay<Dict> { // – it is the same as LegacyErrorInfo. Can generically be done.
  private(set) var dictionary: Dict
}

// Should ErrorInfo be codable? does json allow the same key several times?
// ? Decode merged OrderedDictionary as Swift.Dectionary but with key-value ordering

// line: UInt = #line -> UInt16 (65k lines per file seems enough for average usage) | test file size in script

enum MerrorInfoSourcesOptions {
  // omitEqualValuesInsideSource
  // omitEqualValuesAcrossSources
  // collapseNilValues
}

public enum Merge {}

// !! there should be an ability te remove duplicated values for the same key inside / across errorInfoSources, but the
// knowledge that this duplicates happened should be put to the result dictionary.

// Before logging, typically some fields are added to summary info: "#log_file_line", "#log_throttling" ...
// Such info can be added to a separate ErrorInfo instance and put first to `errorInfoSources` arg list.

// Error-chain string (with log / merge / other options) can be added to remote config.
// e.g.: add typeInfo, keyTags.

// !! Make possible to provide Collection<(Key, Value)> for errorInfoSources arg and for errorInfoKeyPath arg

// SwiftCollections.Uniqie can help make `collapse nil values` option. (UniquedSequence | projection)

// Examples for:
// - NSError
// - Swift.Error
// - ErrorsSuite

// arg: addPrefix prefixBuilder: (?) -> String = .errorSignature

// error.domain.removingPrefix("ErrorDomain")

// _specialize(elements, for: BitArray.SubSequence.self)

extension Merge {
  // 1. Find collisions across errorInfo sources (typically it is errors)
  // 2. Iterate over key-value pairs in each errorInfo source.
  // 3. Collisions
  // 3.1 If there is cross collision (the same key in info of several errors), then sourceSignature (e.g. error domain + code)
  // is added to key. If several errors have the same signature (rare in practice), then index from errorInfoSources is also added.
  // In such a way key across errorInfoSources become unique.
  // 3.2 If the same key is met several times inside an errorInfo, then collisionSource interpolation is added to a key.
  // If there are equal collision sources for the same key (e.g. `.onSubscript`), a random suffix
  // will be added (by _putResolvingWithRandomSuffix() func).
  
  typealias EICollection<Key, Value> = Collection<(key: Key, value: Value)>
  
  /// Example:
  /// ```
  ///     Info Source 0                           Info Source 1
  /// +--------------------+                 +--------------------+
  /// |NSCocoaError code 17|                 | NSURLError code 6  |
  /// |--------------------|                 |--------------------|
  /// | key1: 1            |        +        | key2: B            |
  /// | key2: A            |                 | key3: 3            |
  /// +--------------------+                 +--------------------+
  ///                               |
  ///                               v
  ///        +--------------------------------------------+
  ///        |  Summary Info with resolved collisions     |
  ///        |--------------------------------------------|
  ///        | "key1"              : 1                    |
  ///        | "key2 (NSCocoa.17)" : A // (from Source 0) |
  ///        | "key2 (NSURL.6)"    : B // (from Source 1) |
  ///        | "key3"              : 3                    |
  ///        +--------------------------------------------+
  /// ```
  public static func summaryInfo<S, K, V, W>(
    infoSources: [S], // TODO: .reversed support | tests
    infoKeyPath: KeyPath<S, some Collection<(key: K, value: V)>>,
    keyStringPath: KeyPath<K, String>,
    keyOriginPath: KeyPath<K, KeyOrigin>?,
    valueCollisionPath: KeyPath<V, CollisionSource?>?,
    annotationsFormat: KeyAnnotationsFormat,
    infoSourceSignatureBuilder: @escaping (S) -> String,
    valueTransform: (V) -> W,
    collisionSourceInterpolation: (CollisionSource) -> String = { $0.defaultStringInterpolation() },
  )
    -> OrderedDictionary<String, W> {
    // any ErrorInfoValueType change to V (e.g. to be Optional<any ErrorInfoValueType> or String)
    typealias Key = String
    
    var summaryInfo: OrderedDictionary<Key, W> = [:]
    func putResolvingCollisions(key assumeModifiedKey: Key, value processedValue: W) {
      ErrorInfoDictFuncs.Merge._putResolvingWithRandomSuffix(processedValue,
                                                             assumeModifiedKey: assumeModifiedKey,
                                                             shouldOmitEqualValue: false,
                                                             suffixFirstChar: ErrorInfoMerge.suffixBeginningForMergeScalar,
                                                             to: &summaryInfo)
    }
    
    // context is a var only because of mutating get / lazy var
    var context = prepareMergeContext(infoSources: infoSources,
                                      infoKeyPath: infoKeyPath,
                                      keyString: keyStringPath,
                                      infoSourceSignatureBuilder: infoSourceSignatureBuilder)
    
    for (infoSourceIndex, errorInfo) in context.errorInfos.enumerated() {
      for (key, value) in errorInfo {
        let keyString = key[keyPath: keyStringPath]
        
        var augmentedKey = keyString // _StatefulKey(key.string)
                
        let collisionSource: CollisionSource? = if let valueCollisionPath {
          value[keyPath: valueCollisionPath]
        } else {
          nil
        }
        
        let annotationsSuffix = _makeAnnotations(keyString: keyString,
                                                 keyOrigin: keyOriginPath.map { key[keyPath: $0] },
                                                 collisionSource: collisionSource,
                                                 infoSourceIndex: infoSourceIndex,
                                                 context: &context,
                                                 annotationsFormat: annotationsFormat,
                                                 collisionInterpolation: collisionSourceInterpolation)
        augmentedKey.append(annotationsSuffix)
        
        let adaptedValue = valueTransform(value)
        putResolvingCollisions(key: augmentedKey, value: adaptedValue)
      } // end `for (key, value)`
    } // end `for (errorIndex, error)`
    
    return summaryInfo
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Key Annotations

extension Merge {
  /// Decomposition of `merge` function. `
  private static func _makeAnnotations(keyString: String,
                                       keyOrigin: KeyOrigin?,
                                       collisionSource: CollisionSource?,
                                       infoSourceIndex: Int,
                                       context: inout SummaryPreparationContext<some Any>,
                                       annotationsFormat: KeyAnnotationsFormat,
                                       collisionInterpolation: (CollisionSource) -> String) -> String {
    let keyHasCollisionAcross = context.keyDuplicatesAcrossSources.contains(keyString)
    let keyHasCollisionWithin = context.keyDuplicatesWithinSources[infoSourceIndex].contains(keyString)
    
    // When there is cross collision, add sourcesSignature to distinguish the same key from different errors
    let errorInfoSignature: String? = keyHasCollisionAcross ? context.uniqueSourcesSignatures[infoSourceIndex] : nil
    
    let keyOriginString: String?
    if let keyOrigin {
      let keyOriginPolicy = annotationsFormat.keyOriginPolicy
      let keyHasCollision = keyHasCollisionAcross || keyHasCollisionWithin
      let keyOriginOptions = keyHasCollision ? keyOriginPolicy.whenCollision : keyOriginPolicy.whenUnique
      
      keyOriginString = if keyOriginOptions.matches(keyOrigin: keyOrigin) {
        annotationsFormat.keyOriginInterpolation(keyOrigin)
      } else {
        nil
      }
    } else {
      keyOriginString = nil
    }
    
    let collisionSource: String? = collisionSource.map(collisionInterpolation)
    
    var annotationsBuffer = "" // TODO: ?append to key directly without allocationg annotationsBuffer
    _appendAnnotations(keyOrigin: keyOriginString,
                       collisionSource: collisionSource,
                       errorInfoSignature: errorInfoSignature,
                       annotationsFormat: annotationsFormat,
                       to: &annotationsBuffer)
    
    return annotationsBuffer
  }
    
  private static func _appendAnnotations(keyOrigin: String?,
                                         collisionSource: String?,
                                         errorInfoSignature: String?,
                                         annotationsFormat: KeyAnnotationsFormat,
                                         to recipient: inout String) {
    // 1. Fast path
    if keyOrigin == nil, collisionSource == nil, errorInfoSignature == nil { return }
    
    // 2. Compute the exhaustive order
    let exhaustiveOrder: OrderedSet<Merge.AnnotationComponentKind>
    do {
      let allAnnotationKinds = Merge.AnnotationComponentKind.allCases
      let requestedOrder = annotationsFormat.annotationsOrder
      if requestedOrder.count == allAnnotationKinds.count {
        exhaustiveOrder = requestedOrder
      } else {
        exhaustiveOrder = requestedOrder.union(allAnnotationKinds)
      }
    }
    
    // 3. Pre-append boundary and keep closing delimiter
    let closingDelimiter: Character?
    switch annotationsFormat.annotationsDelimiters.blockBoundary {
    case let .onlySpacer(spacer):
      recipient.append(spacer)
      closingDelimiter = nil
    case let .enclosure(spacer, opening, closing):
      recipient.append(spacer); recipient.append(opening)
      closingDelimiter = closing
    }
    
    // 4. Append components in one tight loop.
    // In most cases all components are nil (as they are typically added when collision happen)
    var needsSeparator = false // no separator is needed before first component
    for currentComponentKind in exhaustiveOrder {
      let currentComponent: String? = switch currentComponentKind {
      case .keyOrigin: keyOrigin
      case .collisionSource: collisionSource
      case .errorInfoSignature: errorInfoSignature
      }
      
      if let currentComponent {
        if needsSeparator {
          recipient.append(annotationsFormat.annotationsDelimiters.componentsSeparator)
        } else {
          needsSeparator = true // when first non-nil component appears, toggle to true for next components
        }
        recipient.append(currentComponent)
      }
    }
    
    // 5. Close enclosure if needed
    if let closingDelimiter { recipient.append(closingDelimiter) }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Context

extension Merge {
  /// infoSources.count and keyDuplicatesWithinSources.count, sourcesSignatures.count, errorInfos.count MUST be equal
  private struct SummaryPreparationContext<ErrInfo>: ~Copyable {
    let keyDuplicatesAcrossSources: Set<String>
    let keyDuplicatesWithinSources: [Set<String>]
    
    private let _generateUniqueSourceSignatures: () -> [String]
    private(set) lazy var uniqueSourcesSignatures: [String] = _generateUniqueSourceSignatures()
    
    let errorInfos: [ErrInfo]
    
    init(keyDuplicatesAcrossSources: Set<String>,
         keyDuplicatesWithinSources: [Set<String>],
         generateUniqueSourceSignatures: @escaping () -> [String],
         errorInfos: [ErrInfo]) {
      self.keyDuplicatesAcrossSources = keyDuplicatesAcrossSources
      self.keyDuplicatesWithinSources = keyDuplicatesWithinSources
      _generateUniqueSourceSignatures = generateUniqueSourceSignatures
      self.errorInfos = errorInfos
    }
  }
  
  private static func prepareMergeContext<S, K, V, ErrInfo>(infoSources: [S],
                                                            infoKeyPath: KeyPath<S, ErrInfo>,
                                                            keyString: KeyPath<K, String>,
                                                            infoSourceSignatureBuilder: @escaping (S) -> String)
    -> SummaryPreparationContext<ErrInfo> where ErrInfo: EICollection<K, V> {
    let errorInfos = infoSources.map { $0[keyPath: infoKeyPath] }
    
    // let duplicates = findDuplicateElements(in: errorInfos.map { $0.allKeys })
    let duplicates = findDuplicateElements(in: errorInfos.map { errorInfo in
      AnyCollectionProjectable(base: errorInfo, elementProjection: { element in element.key[keyPath: keyString] })
    })
        
    let generateUniqueSourceSignatures: () -> [String] = {
      _generateUniqueSignatures(forSources: infoSources, buildSignatureForSource: infoSourceSignatureBuilder)
    }
    
    return SummaryPreparationContext(keyDuplicatesAcrossSources: duplicates.duplicatesAcrossSources,
                                     keyDuplicatesWithinSources: duplicates.duplicatesWithinSources,
                                     generateUniqueSourceSignatures: generateUniqueSourceSignatures,
                                     errorInfos: errorInfos)
  }
  
  private static func _generateUniqueSignatures<S>(forSources sources: [S],
                                                   buildSignatureForSource: (S) -> String) -> [String] {
    var signatureStatuses: [String: _SignatureStatus] = Dictionary(minimumCapacity: sources.count)
    var uniqueSignatures: [String] = Array(minimumCapacity: sources.count)
    
    for sourceIndex in sources.indices {
      let rawSignature = buildSignatureForSource(sources[sourceIndex])
      
      let signatureToAppend: String
      // Check if the raw signature already exists in the signature status map
      if let occurenceIndex = signatureStatuses.index(forKey: rawSignature) {
        let status = signatureStatuses.values[occurenceIndex]
        switch status {
        case .isFirstOccurrence(let previousIndex):
          // When a duplicate happens, replace initially created rawSignature with an indexed version
          uniqueSignatures[previousIndex] = makeIndexedSignature(rawSignature: rawSignature, index: previousIndex)
          signatureStatuses.values[occurenceIndex] = .alreadyMadeUnique
        case .alreadyMadeUnique:
          break
        }
        
        // Add the new indexed signature for this occurrence of duplicated rawSignature
        signatureToAppend = makeIndexedSignature(rawSignature: rawSignature, index: sourceIndex)
      } else {
        signatureStatuses[rawSignature] = .isFirstOccurrence(atIndex: sourceIndex)
        signatureToAppend = rawSignature
      }
      uniqueSignatures.append(signatureToAppend)
    }
    
    return uniqueSignatures
  }
  
  private static func makeIndexedSignature(rawSignature: String, index: Int) -> String {
    rawSignature + "(\(index))"
  }
  
  private enum _SignatureStatus {
    case isFirstOccurrence(atIndex: Int)
    case alreadyMadeUnique
  }
  
  /// Analyzes a group of collections and detects duplicate elements both within each collection and across different collections.
  ///
  /// Pperforms two levels of duplicate detection:
  ///
  /// 1. **Duplicates across sources**
  ///    An element is considered a *cross-source duplicate* if it appears in two or more *different* collections—regardless of how many
  ///    times it appears inside each collection.
  ///
  /// 2. **Duplicates within sources**
  ///    For each individual collection, any element that appears two or more times inside that same collection is reported as an
  ///    *intra-source duplicate*.
  ///
  /// - Note:
  ///   An element that repeats three times in one collection but never appears in other collections will only appear in `duplicatesWithinSources`, not
  ///   in `duplicatesAcrossSources`.
  ///
  /// - Parameter collections: The list of collections to analyze. Each collection must contain hashable elements.
  ///
  /// - Returns: A tuple containing:
  ///   - `duplicatesAcrossSources`:
  ///     A set of elements that appear in at least two different collections.
  ///
  ///   - `duplicatesWithinSources`:
  ///     An array where each element is the set of duplicates *within* the
  ///     corresponding input collection.
  ///
  /// - Complexity:
  ///   Time: **O(N)**
  ///   Space: **O(N)**
  ///
  /// # Examples
  ///
  /// ```swift
  /// let collections = [
  ///   [1, 2, 3],
  ///   [3, 4, 5],
  ///   [6, 1, 1]
  /// ]
  ///
  /// let result = findDuplicateElements(in: collections)
  ///
  /// // Elements that appear in ≥2 different collections:
  /// result.duplicatesAcrossSources        // {1, 3}
  ///
  /// // Per-collection duplicates:
  /// // Collection #0: [1,2,3] → none
  /// // Collection #1: [3,4,5] → none
  /// // Collection #2: [6,1,1] → element `1` is duplicated
  /// result.duplicatesWithinSources // [[], [], [1]]
  /// ```
  private static func findDuplicateElements<C: Collection>(in collections: [C])
    -> (duplicatesAcrossSources: Set<C.Element>, duplicatesWithinSources: [Set<C.Element>]) where C.Element: Hashable {
    guard collections.count > 1 else { return ([], []) }
      
    /// Tracks how many distinct collections contain each element
    var globalOccurrenceCount: [C.Element: Int] // | CountedMultiSet
    do {
      // TODO: - not Unique now, fix comments
      // Unique collection types has .count O(1):
      let totalApproxCount = collections.reduce(into: 0) { count, set in count += set.count }
      globalOccurrenceCount = Dictionary(minimumCapacity: totalApproxCount)
      // in most cases, keys across errorInfo instances are unique, thats why capacity for totalCount can be allocated.
      // If there are duplicated elements across collections, memory overhead will be minimal in real scenarios.
    }
    
    /// Tracks duplicates *within* each collection
    var duplicatesWithinSources = [Set<C.Element>](minimumCapacity: collections.count)
      
    for collection in collections {
      var localCounts: [C.Element: Int] = [:] // | CountedMultiSet
      for element in collection {
        let isFirstOccurrenceInThisCollection = !localCounts.hasValue(forKey: element)
        if isFirstOccurrenceInThisCollection {
          globalOccurrenceCount[element, default: 0] += 1
        }
        localCounts[element, default: 0] += 1
      }
      
      // Extract per-collection duplicates
      var intraDuplicates: Set<C.Element> = []
      for (element, count) in localCounts where count > 1 {
        intraDuplicates.insert(element)
      }
      duplicatesWithinSources.append(intraDuplicates)
    }
    
    // Extract cross-source duplicates
    var duplicatesAcrossSources: Set<C.Element> = []
    for (element, count) in globalOccurrenceCount where count > 1 {
      duplicatesAcrossSources.insert(element)
    }
    return (duplicatesAcrossSources, duplicatesWithinSources)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

extension Merge {
  
  fileprivate struct _StatefulKey: ~Copyable {
    private var string: String
    private var isSuffixAppended: Bool
    
    init(_ string: String) {
      self.string = string
      isSuffixAppended = false
    }
    
    mutating func append(_ other: String) {
      if !isSuffixAppended {
        string.append(" | ")
        isSuffixAppended = true
      }
      string.append(other)
    }
    
    consuming func finalizedString() -> String {
      string
    }
    
    // mutating func prepend(_ prefix: String) {
    //   string = prefix + " " + string
    // }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

/// worst case: O(n^2/2)
/// best case: O(n-1)
///
/// Example with processing steps:
/// 01112323214
/// 01    23232  4
/// 01    233      4
/// 01234             – output
func extractUniqueElements<T>(from values: NonEmptyArray<T>, equalFuncImp: (T, T) -> Bool) -> NonEmptyArray<T> {
  // TODO: return NonEmptyArray<DiscontiguousSlice<[T]>> to prevemt heap allocation, slice: ~Escaping with `values` lifetime
  var processed: NonEmptyArray<T> = NonEmptyArray<T>(values.first)
  // Improvement: wrap NonEquatable elements to Any[EqualityKind], and use Set, instead of elementwise comparison.
  // TODO: try to use use Algorithms.UniquedSequence.init(base:, projections:)
  // perfomance (may be best olgorithm will be different for different elements count)
  var currentElement = values.first
  var nextElementsSlice = values.base.dropFirst()
  var uniqueElementsSlice = nextElementsSlice
  while !nextElementsSlice.isEmpty {
    let duplicatedElementsIndices = nextElementsSlice.indices(where: { nextElement in
      equalFuncImp(currentElement, nextElement)
    })
    nextElementsSlice.removeSubranges(duplicatedElementsIndices) // ?? use DiscontiguousSlice<[T]>
    uniqueElementsSlice.removeSubranges(duplicatedElementsIndices)
    if let nextElement = nextElementsSlice.first {
      currentElement = nextElement
      nextElementsSlice = nextElementsSlice.dropFirst()
    }
  }
  processed.append(contentsOf: uniqueElementsSlice)
  return processed
}

// JM4 ["decodingDate": date0, // collide with ME14
//      "T.Type": type0, // collide with NE2
//      "id": 0, // collide with ME14 & NE2
//      "uid" 9, // collide with ME14 & NE2, but value is equal with ME14
//      "jm":  "jm"]
// ME14 ["decodingDate": date1,
//       "timeStamp": time0, // collide with NE2
//       "id": 1,
//       "uid" 9,
//       "me": "me"]
// NE2 ["T.Type": type1,
//      "timeStamp": time1,
//      "id": 2,
//      "uid" 0,
//      "ne": "ne"]
// =>
// [
//   "decodingDate_JM4": date0
//   "T.Type_JM4": type0
//   "id_JM4": 0
//   "jm": "jm"
//   "decodingDate_ME14": date1
//   "timeStamp_ME14": time0
//   "id_ME14": 1
//   "me": "me"
//   "T.Type_NE2": type1
//   "timeStamp_NE2": time1
//   "id_NE2": 2
//   "ne": "ne"
// ]

/*
 NSCocoaErrorDomain
 NSURLErrorDomain
 kCFErrorDomainPOSIX
 kCFErrorDomainOSStatus
 kCFErrorDomainMach
 SKErrorDomain
 
 NSCocoaErrorDomain
 NSPOSIXErrorDomain
 NSOSStatusErrorDomain
 NSMachErrorDomain
 NSStreamSOCKSErrorDomain
 NSStreamSocketSSLErrorDomain
 */

/*
 /// O(2n)
 ///
 /// ```
 /// let set1: Set<Int> = [1, 2, 3, 4, 5]
 /// let set2: Set<Int> = [3, 4, 5, 6]
 /// let set3: Set<Int> = [4, 5, 7, 8]
 ///
 /// findCommonElements(inAnyOf: [set1, set2, set3])
 /// // Output: [3, 4, 5]
 /// // because 3 appears in 2 sets, 4 and 5 appear in all 3
 /// ```
 private static func findCommonElements<Unique>(across collections: [Unique]) -> Set<Unique.Element>
   where Unique: Collection & _UniqueCollection, Unique.Element: Hashable {
   guard collections.count > 1 else { return [] }
     
   var countedElements: [Unique.Element: Int] = [:]
   do {
     // Unique collection types has .count O(1):
     let capacity = collections.reduce(into: 0) { count, set in count += set.count }
     countedElements.reserveCapacity(capacity)
     // in most cases, keys across errorInfo instances are unique, thats why capacity for totalCount can be allocated.
     // If there are duplicated elements across collections, memory overhead will be minimal in real scenarios.
   }
   
   for collectionOfUniqueElements in collections {
     for element in collectionOfUniqueElements {
       countedElements[element, default: 0] += 1
     }
   }
   
   var commonElements: Set<Unique.Element> = []
   for (element, count) in countedElements where count > 1 {
     commonElements.insert(element)
   }
   return commonElements
 }
 */
