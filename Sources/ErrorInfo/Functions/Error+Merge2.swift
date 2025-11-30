//
//  Error+Merge2.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 03/10/2025.
//

private import SwiftyKit
private import Algorithms
import protocol InternalCollectionsUtilities._UniqueCollection

struct ProtoError {
  let code: Int
  let domain: String
  let info: OrderedDictionary<String, Int>
}

/// Add partial functionality of collisions resolution to dictionary
struct DictionaryErrorInfoOverlay<Dict> {
  private(set) var dictionary: Dict
}

func playMerge(errors: [any InformativeError]) {
  _ = errors
}

// Should ErrorInfo be codable? does json allow the same key several times?
// ? Decode merged OrderedDictionary as Swift.Dectionary but with key-value ordering

enum MerrorInfoSourcesOptions {
  // omitEqualValuesInsideSource
  // omitEqualValuesAcrossSources
  // collapseNilValues
}

public enum Merge {}

extension Merge {
  struct KeyTagOptions {
    // addKeyTagsForKinds(.allKeyKinds, .allExceptLiterals | .literal, .combinedLiteral, .dynamic, .keyPath, .madified)
  }
  
  struct NilOptions {
    // keepAll
    // collapse | with info is it a nil or a collapsed nil. "nil" "nil (collapsed)" "nil (collapsed, was: Int, String, Array)"
  }
}

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

extension Merge {
  func summaryInfo<S, V, W>(
    infoSources: some BidirectionalCollection<S>, // TODO: .reversed support | tests
    infoKeyPath: KeyPath<S, ErrorInfo>,
    infoSourceSignatureBuilder: (S) -> String,
    valueTransform: (ErrorInfo._Optional) -> W,
    collisionSourceInterpolation: (CollisionSource
    ) -> String = { $0.defaultStringInterpolation() },
  )
  -> OrderedDictionary<String, W> where S: Sequence, S.Element == (key: String, value: V) {
    // any ErrorInfoValueType change to V (e.g. to be Optional<any ErrorInfoValueType> or String)
    typealias Key = String
    typealias Value = any ErrorInfoValueType
    
    var summary: OrderedDictionary<Key, W> = [:]
    
    func putResolvingCollisions(key assumeModifiedKey: Key, value processedValue: W) {
      ErrorInfoDictFuncs.Merge._putResolvingWithRandomSuffix(processedValue,
                                                             assumeModifiedKey: assumeModifiedKey,
                                                             shouldOmitEqualValue: false,
                                                             suffixFirstChar: ErrorInfoMerge.suffixBeginningForMergeScalar,
                                                             to: &summary)
    }
    
    // 1. Find collisions across errorInfo sources (typically it is errors)
    let crossCollisionKeys = findCommonElements(across: infoSources.map { $0[keyPath: infoKeyPath].uniqueKeys })
    
    // 2. Iterate over key-value pairs in each errorInfo source.
    lazy var allSourcesSignatures = infoSources.map(infoSourceSignatureBuilder)
    for (infoSourceIndex, errorInfoSource) in infoSources.enumerated() {
      let errorInfo = errorInfoSource[keyPath: infoKeyPath]
      for (key, value) in errorInfo._storage {
        // 3. Collisions
        // 3.1 If there is cross collision (the same key in info of several errors), then sourceSignature (e.g. error domain + code)
        // is added to key. If several errors have the same signature, then source index from errorInfoSources is also added.
        // In such a way all keys across errorInfoSources become unique.
        // 3.2 If the same key is met several times inside an errorInfo, then collisionSource interpolation is added to a key.
        // If there are equal collision sources for the same key (e.g. `.onSubscript`), a random suffix
        // will be added (by _putResolvingWithRandomSuffix() func).
        
        var augmentedKey = _StatefulKey(key)
        
        let shouldAddKeyKind = false
        if shouldAddKeyKind {
          // add key tag according to options
        }
        
        let hasCrossErrorsCollision = crossCollisionKeys.contains(key)
        if hasCrossErrorsCollision {
          let sourceSignature = _unchecked_infoSourceSignatureForCrossCollision(infoSourceIndex: infoSourceIndex,
                                                                                allSourcesSignatures: allSourcesSignatures)
          augmentedKey.append(sourceSignature)
        }
        
        // TODO: In this kind of summary-merge it is reasonable to provide an option if nil values with different Optional.Wrapped
        // types should be put to summary.
        // TODO: add KeyKind.shortSign()
        // TODO: collisionSource arg unused
        
        // will be multiple values for key later when MultivalueDict types used
        // TODO: use a slice or view to prevent heap allocation
        // TODO: after removingEqualValues there may be collisionSources, e.g. after  removingEqualValues there will be only
        // 1 value with collisionSource. This collisionSource can be skipped as the value is unique and result dictionary
        // will not contain approx. equal values. However, in general case this collisionSource should still be attached to the key
        // for handling the fact that collision occured. The total elimination of collisionSource can be done by passing additional
        // argument or option to this function
  //      let processedValues = prepareValues(NonEmptyArray(value), removingEqualValues: omitEqualValues)
        // TODO: processedValues contain all values for key which leads to incorrect ordering.
        
        if let collisionSource = value.collisionSource {
          let collisionString = collisionSourceInterpolation(collisionSource)
          augmentedKey.append(collisionString)
        }
        // value collisions within concrete error instance | crossCollisions
        let adaptedValue = valueTransform(value.value)
        putResolvingCollisions(key: augmentedKey.string, value: adaptedValue)
      } // end `for (key, value)`
    } // end `for (errorIndex, error)`
    
    return summary
  }
}



fileprivate struct _StatefulKey {
  private(set) var string: String
  private(set) var isSuffixAppended: Bool
  
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
  
  // mutating func prepend(_ prefix: String) {
  //   string = prefix + " " + string
  // }
}

/// Decomposition of `merge` function. `allSourcesSignatures.count` must be equal to `errorInfoSources.count`
///
/// returns: e.g.: NE2 | ME12(0)
private func _unchecked_infoSourceSignatureForCrossCollision(infoSourceIndex: Int,
                                                             allSourcesSignatures: [String]) -> String {
  var sourceSignature = allSourcesSignatures[infoSourceIndex]
  
  for (index, signature) in allSourcesSignatures.enumerated() where index != infoSourceIndex {
    if sourceSignature == signature {
      // if there are errors with equal signatures then append sourceIndex to understand (by index) from which of
      // similar errors the key-value is.
      sourceSignature.append("(\(infoSourceIndex))")
      return sourceSignature
    }
  }
  return sourceSignature
}

// ?naming merge-FlatMap operation
func merge2(errors: [ProtoError],
            omitEqualValues: Bool, // = false
            errorSignatureBuilder: (ProtoError) -> String = { $0.domain + "\($0.code)" },
            collisionSourceInterpolation: (CollisionSource) -> String = { $0.defaultStringInterpolation() })
  -> OrderedDictionary<String, Int> {
  typealias Dict = OrderedDictionary<String, Int>
  typealias Key = Dict.Key
  typealias Value = Dict.Value
  
  var merged: OrderedDictionary<Key, Value> = [:]
    
  func putResolvingCollisions(key assumeModifiedKey: Key, value processedValue: Value) {
    ErrorInfoDictFuncs.Merge._putResolvingWithRandomSuffix(processedValue,
                                                           assumeModifiedKey: assumeModifiedKey,
                                                           shouldOmitEqualValue: omitEqualValues,
                                                           suffixFirstChar: ErrorInfoMerge.suffixBeginningForMergeScalar,
                                                           to: &merged)
  }
  
  let crossErrorsCollisionKeys = findCommonElements(across: errors.map { $0.info.keys })
  lazy var errorSignatures = errors.map(errorSignatureBuilder)
  for (errorIndex, error) in errors.enumerated() {
    for (key, value) in error.info {
      // will be multiple values for key later when MultivalueDict types used
      // TODO: use a slice or view to prevent heap allocation
      let processedValues = prepareValues(NonEmptyArray(value), removingEqualValues: omitEqualValues)
      let hasCrossErrorsCollision = crossErrorsCollisionKeys.contains(key)
      // TODO: processedValues contain all values for key which leads to incorrect ordering.
      // TODO: after removingEqualValues there may be collisionSources, e.g. after  removingEqualValues there will be only
      // 1 value with collisionSource. This collisionSource can be skipped as the value is unique and result dictionary
      // will not contain approx. equal values. However, in general case this collisionSource should still be attached to the key
      // for handling the fact that collision occured. The total elimination of collisionSource can be done by passing additional
      // argument or option to this function
      var augmentedKey: String = key
      if hasCrossErrorsCollision {
        let errorSignature = errorSignatures[errorIndex]
        augmentedKey.append(errorSignature)
        // TODO: In this kind of summary-merge it is reasonable to provide an option if nil values with different Optional.Wrapped
        // types should be put to summary.
        var allTheRestSignaturesIndices = RangeSet(errorSignatures.indices)
        allTheRestSignaturesIndices.remove(errorIndex, within: errorSignatures)
        
        let isContinedInErrorWithEqualSignature = errorSignatures[allTheRestSignaturesIndices].contains(errorSignature)
        if isContinedInErrorWithEqualSignature {
          // if there are errors with same signatures then append errorIndex to understand from which of similar errors
          // the key-value is
          augmentedKey.append("(\(errorIndex))")
        }
      } else {
        ()
      }
      
      if processedValues.count > 1 { // value collisions within concrete error instance
        for collidedValue in processedValues {
          let collisionSource = CollisionSource.onSubscript // !! get real one
          let collisionSourceString = collisionSourceInterpolation(collisionSource)
          augmentedKey.append(collisionSourceString)
          putResolvingCollisions(key: augmentedKey, value: collidedValue)
        }
      } else {
        putResolvingCollisions(key: augmentedKey, value: processedValues.first)
      }
    } // end `for (key, value)`
  } // end `for (errorIndex, error)`
  
  return merged
}

fileprivate func prepareValues<T>(_ values: NonEmptyArray<T>, removingEqualValues: Bool) -> NonEmptyArray<T> {
  guard removingEqualValues else { return values }
  return extractUniqueElements(from: values, equalFuncImp: ErrorInfoFuncs.isEqualAny)
}

/// worst case: O(n^2/2)
/// best cases: O(n-1)
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
func findCommonElements<Unique>(across collections: [Unique]) -> Set<Unique.Element>
  where Unique: Collection & _UniqueCollection, Unique.Element: Hashable {
  guard collections.count > 1 else { return [] }
    
  var countedElements: [Unique.Element: Int] = [:]
  do {
    // Unique collection types has .count O(1):
    let capacity = collections.reduce(into: 0) { count, set in count += set.count }
    countedElements.reserveCapacity(capacity)
    // in most cases, keys across errorInfo instances are unique, thats why capacity for totalCount can be allocated.
    // If there are duplicated elements across collections, memory overhead will be minimal
  }
  
//   var commonElementsCapacity: Int = 0
  for collectionOfUniqueElements in collections {
    for element in collectionOfUniqueElements {
      countedElements[element, default: 0] += 1
      
      // ?Improvement:
//       var count = countedElements[element, default: 0]
//       switch count {
//       case 0:
//         countedElements[element] = 1
//       case 1:
//         count += 1
//         countedElements[element] = count
//         // when element appears second time, it will be added to commonElements. So we can calc commonElements.Capacity
      ////         commonElementsCapacity += 1
//       default:
//         // real count is not needed. It is needed to know if element was met twice
//         break // optimize increment & subscript setter (hash calculatuon + value update)
//       }
    } // end for element
  } // end for collection
  
  var commonElements: Set<Unique.Element> = []
//   commonElements.reserveCapacity(commonElementsCapacity)
  for (element, count) in countedElements where count > 1 {
    commonElements.insert(element)
  }
  return commonElements
}
