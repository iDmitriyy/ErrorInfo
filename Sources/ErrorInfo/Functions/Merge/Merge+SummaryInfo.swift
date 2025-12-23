//
//  Error+Merge2.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 03/10/2025.
//

private import struct OrderedCollections.OrderedSet

// Should ErrorInfo be codable? does json allow the same key several times?
// ? Decode merged OrderedDictionary as Swift.Dectionary but with key-value ordering
// TODO: - ___
// line: UInt = #line -> UInt16 (65k lines per file seems enough for average usage) | test file size in script

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
  /// Representing the availability of collision metadata for an element.
  /// When WriteProvenance is available, the `available` case is used with the corresponding key path to access the metadata.
  /// When WriteProvenance is not available, the `notAvailable` case is used to indicate the absence of collision information.
  public enum CollisionAvailability<Element> {
    case available(keyPath: KeyPath<Element, WriteProvenance?>,
                   interpolation: (WriteProvenance) -> String = { $0.defaultStringInterpolation() })
    case notAvailable
  }
  
  /// Representing the availability of key origin metadata for an element.
  /// When KeyOrigin metadata is available, the `available` case is used with the corresponding key path to access the metadata.
  /// When KeyOrigin is not available, the `notAvailable` case is used to indicate the absence of key origin information.
  public enum KeyOriginAvailability<Element> {
    case available(keyPath: KeyPath<Element, KeyOrigin>,
                   interpolation: (KeyOrigin) -> String = { $0.shortSignInterpolation() })
    case notAvailable
  }
  
  enum PropertyAvailability<R, T> {
    case available(keyPath: KeyPath<R, T>, interpolation: Interpolation<T>)
    case notAvailable
  }
  
  public struct Interpolation<T> { // TODO: tbd
    let interpolation: (KeyOrigin) -> String
    
    // extension Interpolation where T == KeyOrigin {
    //   default = Interpolation { $0.shortSignInterpolation }
    // }
  }
  
  public enum TransformResult<V, N> {
    case value(V)
    case nilInstance(N)
    case skip
  }
}

extension Merge {
  internal enum _Summary {}
}

extension Merge {
  /// Merges key-value pairs from multiple error info sources, handling potential key collisions in a systematic way.
  /// It augments the keys to ensure uniqueness across sources and resolves conflicts by annotating them with metadata such as error source signatures
  /// and collision information.
  ///
  /// ## Key Features
  /// - **Collision Handling Across Sources:** If the same key appears in multiple error info sources, the key is augmented with a source-specific
  ///   signature (e.g., error domain and code).
  ///   In case some of the sources have identical signatures (rare in practice), an index is appended to source signatures to distinguish them.
  ///
  /// - **Collision Handling Within Sources:** If a key appears multiple times within a single error info source, it is annotated with a
  ///   collision source (such as `onSubscript`, `onMerge`).
  ///
  /// - **Customizable Key Prefixing:** Allows you to specify custom key prefixes for each error info source or omit prefixes entirely.
  ///   This is controlled by the `keysPrefixOption` parameter.
  ///
  /// - **Customizable Annotations for Keys:** Keys can be annotated with additional metadata such as the `key's origin`, `collision source`,
  ///   and `error info signature`.
  ///   This is controlled by the `annotationsFormat`, `keyOriginAvailability` and `collisionAvailability` parameters.
  ///
  /// - **Value Transformation:** The function provides a way to transform the values associated with each key. For instance, you can change the value types
  ///   (e.g., from `String` to `Optional<String>`, or apply any other transformation) using the `valueTransform` closure.
  ///
  /// - **Collision Resolution with Random Suffix:** If key collisions still persists after handling across and within-source collisions (highly unlikely in practice),
  ///   a random suffix is appended to the key to ensure its uniqueness.
  ///   This step is a fallback mechanism, ensuring that even in edge cases, keys remain unique.
  ///   This rarely happens, but the function accounts for it by checking if the augmented key already exists in the resulting dictionary and then
  ///   appending a random suffix if necessary.
  ///
  /// - Returns:A merged dictionary with transformed values and unique keys, where collisions are resolved with appropriate key annotations.
  ///
  /// # Example
  /// ```swift
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
  ///        |   Summary Info with resolved collisions    |
  ///        |--------------------------------------------|
  ///        | "key1"              : 1                    |
  ///        | "key2 (NSCocoa.17)" : A // (from Source 0) |
  ///        | "key2 (NSURL.6)"    : B // (from Source 1) |
  ///        | "key3"              : 3                    |
  ///        +--------------------------------------------+
  /// ```
  public static func summaryInfo<S, K, V, EInf, W>(
    infoProviders: [S],
    infoKeyPath: KeyPath<S, EInf>,
    elementKeyStringPath: KeyPath<K, String>,
    keyOriginAvailability: KeyOriginAvailability<EInf.Element>,
    collisionAvailability: CollisionAvailability<EInf.Element>,
    keysPrefixOption: Format.KeysPrefixOption<S>,
    annotationsFormat: Format.KeyAnnotationsFormat,
    randomGenerator: consuming some RandomNumberGenerator & Sendable,
    // collisionTracker: CollisionTracker<V>?,
    infoSourceSignatureBuilder: @escaping (S) -> String,
    valueTransform: (V) -> W,
  )
    -> OrderedDictionary<String, W> where EInf: Collection<(key: K, value: V)> {
    // ErrorInfo.ValueExistential change to V (e.g. to be Optional<ErrorInfo.ValueExistential> or String)
    var summaryInfo: OrderedDictionary<String, W> = [:]
    
    // context is a var only because of `mutating get` / lazy var
    var context = _Summary.prepareMergeContext(infoProviders: infoProviders,
                                               infoKeyPath: infoKeyPath,
                                               keyString: elementKeyStringPath,
                                               infoSourceSignatureBuilder: infoSourceSignatureBuilder)
    // Improvement: using of KeyPaths can be slow. Replacing them with closures may have perfpmance boost.
    for infoSourceIndex in infoProviders.indices {
      let errorInfo = context.errorInfos[infoSourceIndex]
      for (elementIndex, element) in errorInfo.enumerated() {
        let augmentedKey = _Summary.augmentedIfNeededKey(infoSources: infoProviders,
                                                         infoSourceIndex: infoSourceIndex,
                                                         element: element,
                                                         elementIndex: elementIndex,
                                                         keyStringPath: elementKeyStringPath,
                                                         context: &context,
                                                         keysPrefixOption: keysPrefixOption,
                                                         annotationsFormat: annotationsFormat,
                                                         keyOriginAvailability: keyOriginAvailability,
                                                         collisionAvailability: collisionAvailability)
        
        let adaptedValue = valueTransform(element.value)
        
        Merge.DictUtils._putAugmentingWithRandomSuffix(assumeModifiedKey: augmentedKey,
                                                       value: adaptedValue,
                                                       suffixFirstChar: Merge.Constants.randomSuffixBeginningForMergeScalar,
                                                       randomGenerator: &randomGenerator,
                                                       to: &summaryInfo)
      } // end `for (key, value)`
    } // end `for (errorIndex, error)`
    
    return summaryInfo
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Key Augmentation (prefix / suffix annotations)

extension Merge._Summary {
  /// **[Decomposition of `summaryInfo(...)`]** function. This is the central formatting function inside the merge algorithm.
  ///
  /// Produces the final, fully-augmented key that will be placed into the resulting merged dictionary.
  /// It performs all key transformations:
  /// - add prefix (if configured)
  /// - detect collisions
  /// - add unique source signature when necessary
  /// - optionally annotate origin or collision metadata
  /// - append all suffix annotations in the correct order
  fileprivate static func augmentedIfNeededKey<S, K, V>(
    infoSources: [S],
    infoSourceIndex: Int,
    element: (key: K, value: V),
    elementIndex: Int,
    keyStringPath: KeyPath<K, String>,
    context: inout SummaryPreparationContext<some Any>,
    keysPrefixOption: Merge.Format.KeysPrefixOption<S>,
    annotationsFormat: Merge.Format.KeyAnnotationsFormat,
    keyOriginAvailability: Merge.KeyOriginAvailability<(key: K, value: V)>,
    collisionAvailability: Merge.CollisionAvailability<(key: K, value: V)>,
  ) -> String {
    let keyString = element.key[keyPath: keyStringPath]
    
    // Determine collision status
    let keyHasCollisionAcross = context.keyDuplicatesAcrossSources.contains(keyString)
    let keyHasCollisionWithin = context.keyDuplicatesWithinSources[infoSourceIndex].contains(keyString)
    
    // Determine prefix
    let prefix = _determinePrefix(keysPrefixOption: keysPrefixOption,
                                  infoSource: infoSources[infoSourceIndex],
                                  infoSourceIndex: infoSourceIndex,
                                  elementIndex: elementIndex)
    
    // When there is cross collision, add sourceSignature to distinguish the same key from info of different errors
    let errorInfoSignature: String? = keyHasCollisionAcross ? context.uniqueSourcesSignatures[infoSourceIndex] : nil
    
    // Determine key origin string
    let keyOrigin = _determineKeyOrigin(element: element,
                                        keyOriginAvailability: keyOriginAvailability,
                                        keyHasCollisionAcross: keyHasCollisionAcross,
                                        keyHasCollisionWithin: keyHasCollisionWithin,
                                        annotationsFormat: annotationsFormat)
        
    let collisionSource = _determineCollisionSource(collisionAvailability: collisionAvailability, element: element)
    
    // Improvement: resultKey.reserveCapacity | reduce CoW / copy | wrap to ~Copyable
    // all strings can be more efficiently concatenated. The concrete effective way depends on if-else branching, including
    // _appendSuffixAnnotations function.
    var resultKey: String = ""
    if let prefix {
      resultKey.append(prefix)
      resultKey.append(keyString)
    } else {
      resultKey = keyString
    }
    // ! try to used Array<String>.joined(separator: String)
    _appendSuffixAnnotations(keyOrigin: keyOrigin,
                             collisionSource: collisionSource,
                             errorInfoSignature: errorInfoSignature,
                             annotationsFormat: annotationsFormat,
                             to: &resultKey)
    
    //    collisionTracker?._addRecord(key: keyString,
    //                                 value: element.value,
    //                                 keyHasCollisionAcross: keyHasCollisionAcross,
    //                                 keyHasCollisionWithin: keyHasCollisionWithin,
    //                                 sourceSignature: errorInfoSignature)
    return resultKey
  }
  
  /// **[Decomposition of `augmentedIfNeededKey(...)`]** function.
  internal static func _determinePrefix<S>(keysPrefixOption: Merge.Format.KeysPrefixOption<S>,
                                           infoSource: S,
                                           infoSourceIndex: Int,
                                           elementIndex: Int) -> String? {
    switch keysPrefixOption {
    case .noPrefix:
      return nil
    case let .customPrefix(boundaryDelimiter, keyPrefixBuilder):
      let component = keyPrefixBuilder(infoSource, infoSourceIndex, elementIndex)
      return _makePrefixString((component, boundaryDelimiter))
    }
  }
  
  /// **[Decomposition of `augmentedIfNeededKey(...)`]** function.  Builds the prefix text for a key.
  ///
  /// # Example
  /// ```swift
  /// _makePrefixString(("err1",
  ///                   .enclosure(spacer: " ", opening: "[", closing: "]")))
  ///
  /// // output:                "[err1] "
  /// // So a key "id" becomes: "[err1] id"
  /// ```
  internal static func _makePrefixString(_ input: (component: String, blockBoundary: Merge.Format.AnnotationsBoundaryDelimiter)) -> String {
    let (component, blockBoundary) = input
    
    var prefix = ""
    
    let closingDelimiter: Character?
    let spacerStr: String
    switch blockBoundary {
    case let .onlySpacer(spacer):
      closingDelimiter = nil
      spacerStr = spacer
      // Improvement: prefix.reserveCapacity(spacer.utf8.count + component.utf8.count)
      
    case let .enclosure(spacer, opening, closing):
      // Improvement: prefix.reserveCapacity(opening.utf8.count + component.utf8.count + closing.utf8.count + spacer.utf8.count)
      prefix.append(opening)
      closingDelimiter = closing
      spacerStr = spacer
    }
    
    prefix.append(component)
    if let closingDelimiter { prefix.append(closingDelimiter) }
    prefix.append(spacerStr)
    return prefix
  }
  
  /// **[Decomposition of `augmentedIfNeededKey(...)`]** function.
  internal static func _determineKeyOrigin<K, V>(element: (key: K, value: V),
                                                 keyOriginAvailability: Merge.KeyOriginAvailability<(key: K, value: V)>,
                                                 keyHasCollisionAcross: Bool,
                                                 keyHasCollisionWithin: Bool,
                                                 annotationsFormat: Merge.Format.KeyAnnotationsFormat) -> String? {
    switch keyOriginAvailability {
    case let .available(keyOriginPath, interpolation):
      let keyHasCollision = keyHasCollisionAcross || keyHasCollisionWithin
      let keyOriginPolicy = annotationsFormat.keyOriginPolicy
      let keyOriginOptions = keyHasCollision ? keyOriginPolicy.whenCollision : keyOriginPolicy.whenUnique
          
      let keyOrigin = element[keyPath: keyOriginPath]
      return keyOriginOptions.matches(keyOrigin: keyOrigin) ? interpolation(keyOrigin) : nil
    case .notAvailable:
      return nil
    }
  }
  
  /// **[Decomposition of `augmentedIfNeededKey(...)`]** function.
  internal static func _determineCollisionSource<K, V>(collisionAvailability: Merge.CollisionAvailability<(key: K, value: V)>,
                                                       element: (key: K, value: V)) -> String? {
    switch collisionAvailability {
    case let .available(keyPath, interpolation):
      let collision: WriteProvenance? = element[keyPath: keyPath]
      return collision.map(interpolation)
    case .notAvailable:
      return nil
    }
  }
  
  /// **[Decomposition of `augmentedIfNeededKey(...)`]** function.  Builds the suffix part for the key from optional annotations.
  /// It inserts them in the order defined by `annotationsFormat` and wraps them using the configured delimiters.
  /// Nothing is added if all components are nil.
  ///
  /// # Example
  /// ```swift
  /// var key = "id"
  /// _appendSuffixAnnotations(keyOrigin: "literal",
  ///                          collisionSource: "onSubscript(file_line:Main.swift:31)",
  ///                          errorInfoSignature: nil,
  ///                          annotationsFormat: .default,
  ///                          to: &key)
  /// // "id (literal, onSubscript)"
  /// ```
  internal static func _appendSuffixAnnotations(keyOrigin: String?,
                                                collisionSource: String?,
                                                errorInfoSignature: String?,
                                                annotationsFormat: Merge.Format.KeyAnnotationsFormat,
                                                to recipient: inout String) {
    // 1. Fast path
    if keyOrigin == nil, collisionSource == nil, errorInfoSignature == nil { return }
    
    // 2. Compute the exhaustive order
    let exhaustiveOrder: OrderedSet<Merge.Format.AnnotationComponentKind>
    do {
      // Improvement: is `.allCases` computed or static? Should be initialized once (_const / compileTime value)
      let allAnnotationKinds = Merge.Format.AnnotationComponentKind.allCases
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
      recipient.append(spacer)
      recipient.append(opening)
      closingDelimiter = closing
    }
    
    let makeName: (Merge.Format.AnnotationComponentKind) -> String?
    switch annotationsFormat.annotationNameOption {
    case .noNames: makeName = { _ in nil }
    case let .withNames(separator, nameForComponent): makeName = { nameForComponent($0) + separator }
    }
    
    // 4. Append components in one tight loop.
    // In most cases all components are `nil` (as they are typically added when collision happen)
    var needsSeparator = false // no separator is needed before first component
    for currentComponentKind in exhaustiveOrder {
      let component: String? = switch currentComponentKind {
      case .keyOrigin: keyOrigin
      case .collisionSource: collisionSource
      case .errorInfoSignature: errorInfoSignature
      }
      
      if let component {
        if needsSeparator {
          recipient.append(annotationsFormat.annotationsDelimiters.componentsSeparator)
        } else {
          needsSeparator = true // when first `non-nil` component appears, toggle to true for next components
        }
        
        if let componentName = makeName(currentComponentKind) {
          recipient.append(componentName)
        }
        recipient.append(component)
      }
    }
    
    // 5. Close enclosure if needed
    if let closingDelimiter { recipient.append(closingDelimiter) }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Context

extension Merge._Summary {
  /// infoSources.count and keyDuplicatesWithinSources.count, sourcesSignatures.count, errorInfos.count **MUST** be equal
  fileprivate struct SummaryPreparationContext<ErrInfo>: ~Copyable {
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
  
  /// **[Decomposition of `summaryInfo(...)`]** function.
  ///
  /// Builds a compact structure with all preprocessing results needed by the main loop in `summaryInfo function`, including:
  /// - keys duplicated across different sources
  /// - keys duplicated within each source
  /// - a lazily-computed list of unique source signatures
  /// - the extracted errorInfos collections
  ///
  /// This context lets `_augmentedIfNeededKey` function quickly determine how to annotate keys.
  fileprivate static func prepareMergeContext<S, K, V, ErrInfo>(infoProviders: [S],
                                                                infoKeyPath: KeyPath<S, ErrInfo>,
                                                                keyString: KeyPath<K, String>,
                                                                infoSourceSignatureBuilder: @escaping (S) -> String)
    -> SummaryPreparationContext<ErrInfo> where ErrInfo: Collection<(key: K, value: V)> {
    let errorInfoElements = infoProviders.map { $0[keyPath: infoKeyPath] }
    
    // let duplicates = findDuplicateElements(in: errorInfos.map { $0.allKeys })
    let duplicates = _findDuplicateElements(in: errorInfoElements.map { errorInfo in
      errorInfo.lazy.map { element in element.key[keyPath: keyString] }
    })
        
    let generateUniqueSourceSignatures: () -> [String] = {
      _generateUniqueSignatures(forInfoProviders: infoProviders, buildSignatureForSource: infoSourceSignatureBuilder)
    }
    
    return SummaryPreparationContext(keyDuplicatesAcrossSources: duplicates.duplicatesAcrossSources,
                                     keyDuplicatesWithinSources: duplicates.duplicatesWithinSources,
                                     generateUniqueSourceSignatures: generateUniqueSourceSignatures,
                                     errorInfos: errorInfoElements)
  }
    
  /// **[Decomposition of `summaryInfo(...)`]** function. Generates a unique string signature for each source.
  /// If multiple sources produce the same raw signature, they are disambiguated by appending an index suffix.
  ///
  /// If no duplicates are found, the raw signature is used as is. When duplicates occur, each duplicate gets a unique version by adding
  /// an index (e.g., `signature(0)`, `signature(2)`).
  ///
  /// # Example without duplicates:
  /// ```swift
  /// let sources = [error1, error2, error3]
  /// let buildRawSignature = {
  ///   $0.domain.replacingOccurrences(of: "ErrorDomain", with: "") + ".\($0.code)"
  /// }
  ///
  /// _generateUniqueSignatures(forSources: sources, buildSignatureForSource: buildRawSignature)
  /// // ["NSURL.6", "NSCocoa.17", "NSCocoa.18"]
  /// ```
  ///
  /// # Example with duplicates:
  /// ```swift
  /// // error1 and error3 have the same domain and code (and raw signature)
  /// let sources = [error1, error2, error3]
  /// let buildRawSignature = {
  ///   $0.domain.replacingOccurrences(of: "ErrorDomain", with: "") + ".\($0.code)"
  /// }
  ///
  /// _generateUniqueSignatures(forSources: sources, buildSignatureForSource: buildRawSignature)
  /// // ["NSURL.6(0)", "NSCocoa.17", "NSURL.6(2)"]
  /// ```
  internal static func _generateUniqueSignatures<S>(forInfoProviders infoProviders: [S],
                                                    buildSignatureForSource: (S) -> String) -> [String] {
    var signatureStatuses: [String: _SignatureStatus] = Dictionary(minimumCapacity: infoProviders.count)
    var uniqueSignatures: [String] = Array(minimumCapacity: infoProviders.count)
    
    for infoIndex in infoProviders.indices {
      let rawSignature = buildSignatureForSource(infoProviders[infoIndex])
      
      let signatureToAppend: String
      // Check if the raw signature already exists in the signature status map
      if let occurenceIndex = signatureStatuses.index(forKey: rawSignature) {
        let status = signatureStatuses.values[occurenceIndex]
        switch status {
        case .isFirstOccurrence(let previousIndex):
          // When a duplicate happens, replace initially created rawSignature with an indexed version
          uniqueSignatures[previousIndex] = _makeIndexedSignature(rawSignature: rawSignature, index: previousIndex)
          signatureStatuses.values[occurenceIndex] = .alreadyMadeUnique
        case .alreadyMadeUnique:
          break
        }
        
        // Add the new indexed signature for this occurrence of duplicated rawSignature
        signatureToAppend = _makeIndexedSignature(rawSignature: rawSignature, index: infoIndex)
      } else {
        signatureStatuses[rawSignature] = .isFirstOccurrence(atIndex: infoIndex)
        signatureToAppend = rawSignature
      }
      uniqueSignatures.append(signatureToAppend)
    }
    
    return uniqueSignatures
  }
  
  /// **[Decomposition of `summaryInfo(...)`]** function.
  internal static func _makeIndexedSignature(rawSignature: String, index: Int) -> String {
    rawSignature + "(\(index))"
  }
  
  private enum _SignatureStatus {
    case isFirstOccurrence(atIndex: Int)
    case alreadyMadeUnique
  }
  
  /// **[Decomposition of `summaryInfo(...)`]** function. Analyzes a group of collections and detects duplicate elements both within each collection
  /// and across different collections.
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
  ///   **O(N)**
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
  /// result.duplicatesAcrossSources // [1, 3]
  ///
  /// // Per-collection duplicates:
  /// // Collection #0: [1,2,3] → none
  /// // Collection #1: [3,4,5] → none
  /// // Collection #2: [6,1,1] → element `1` is duplicated
  /// result.duplicatesWithinSources // [[], [], [1]]
  /// ```
  internal static func _findDuplicateElements<C: Collection>(in collections: [C])
    -> (duplicatesAcrossSources: Set<C.Element>, duplicatesWithinSources: [Set<C.Element>]) where C.Element: Hashable {
    guard collections.count > 1 else { return ([], []) }
      
    /// Tracks how many distinct collections contain each element
    var globalOccurrenceCount: [C.Element: Int] // | CountedMultiSet
    do {
      // Collection types typically has .count O(1):
      let totalApproxCount = collections.reduce(into: 0) { count, set in count += set.count }
      globalOccurrenceCount = Dictionary(minimumCapacity: totalApproxCount)
      // in most cases, keys across errorInfo instances are unique, thats why capacity for totalCount can be allocated.
      // If there are duplicated elements across collections, memory overhead will be minimal in real scenarios.
    }
    
    /// Tracks duplicates within each collection
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
