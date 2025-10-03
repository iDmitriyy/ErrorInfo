//
//  Error+Merge2.swift
//  ErrorInfo
//
//  Created by tmp on 03/10/2025.
//

private import SwiftyKit
private import Algorithms

struct StubError {
  let code: Int
  let domain: String
  let info: OrderedDictionary<String, Int>
}

fileprivate enum ErrorInfoIndicesCache<Bound: Comparable> {
  case unbounded
  case bounded(noInterErrorCollisions: RangeSet<Bound>)
}

struct KeyWithIndexPaths<Key: Hashable, ErrorsListIndex, DictIndex> {
  let key: Key
}

// CollisionSourceSpecifier.defaultStringInterpolation
// (CollisionSourceSpecifier) -> String

// ?naming merge-FlatMap operation
func merge2(errors: NonEmptyArray<StubError>,
            omitEqualValues: Bool,
            collisionSpecifierInterpolation: (CollisionSourceSpecifier) -> String)
  -> OrderedDictionary<String, Int> {
  typealias Dict = OrderedDictionary<String, Int>
  typealias Key = Dict.Key
  typealias Value = Dict.Value
    
  guard errors.count > 1 else {
    // FIXME: instance-bounded collisions
    return errors.first.info
  }
  
  // RangSet – can be created while intersections search.
  var notCollidedKeysIndices: [RangeSet<Dict.Index>] = []
  
  let interErrorsCollidedKeys = mutate(value: Set<Key>()) { commonKeys in
    var countedKeys: [Key: Int] = [:]
    
    for (errorIndex, error) in errors.enumerated() {
      for key in error.info.keys {
        countedKeys[key, default: 0] += 1
      }
    }
    
    for (key, count) in countedKeys where count > 1 {
      commonKeys.insert(key)
    }
  }
    
  var merged: OrderedDictionary<Key, Value> = [:]
  
  for error in errors.base {
    let index: Int = 0
    let indicesWithoutInterErrorCollisions = notCollidedKeysIndices[index]
    let elementsWithoutInterErrorCollisions = error.info[indicesWithoutInterErrorCollisions]
    
    for (key, value) in elementsWithoutInterErrorCollisions {
      // will possibly be multiple values for key later when MultivalueDict types used
      var values: NonEmptyArray<Value> = NonEmptyArray(value) // TODO: use a slice or view to prevent heap allocation
      if values.count > 1 { // value collisions within concrete error instance
        let processedValues = prepareValues(values, removingEqualValues: omitEqualValues)
        
        for collidedValue in processedValues {
          let collisionSpecifier = CollisionSourceSpecifier.onSubscript // !! get real one
          let collisionSpecString = collisionSpecifierInterpolation(collisionSpecifier)
          let augmentedKey = key + collisionSpecString
          merged[augmentedKey] = collidedValue // TODO: _putAugmentingWithRandomSuffix()
        }
      } else {
        merged[key] = values.first
      }
    } // end `for (key, value)`
    
    if error.info.count != elementsWithoutInterErrorCollisions.count {
      // TODO: optimize inverted set creation or crated it
      let indicesForInterErrorCollisions = RangeSet(error.info.indices, within: error.info)
        .subtracting(indicesWithoutInterErrorCollisions)
      let elementsWithInterErrorCollisions = error.info[indicesWithoutInterErrorCollisions]
      
      for (key, value) in elementsWithInterErrorCollisions {
        var values: NonEmptyArray<Value> = NonEmptyArray(value) // TODO: use a slice or view to prevent heap allocation
        let augmentedKey = key + error.domain + "\(error.code)"
        if values.count > 1 {
          
        } else {
          merged[augmentedKey] = values.first
        }
      }
    }
   } // end `for error`
  
  return merged
}

fileprivate func prepareValues<T>(_ values: NonEmptyArray<T>, removingEqualValues: Bool) -> NonEmptyArray<T> {
  guard removingEqualValues else { return values }
  return extractApproximatelyUniqueElements(from: values)
}

func extractApproximatelyUniqueElements<T>(from values: NonEmptyArray<T>) -> NonEmptyArray<T> {
  // TODO: return NonEmptyArray<DiscontiguousSlice<[T]>> to prevemt heap allocation, slice: ~Escaping with `values` lifetime
  var processed: NonEmptyArray<T> = NonEmptyArray<T>(values.first)
  
  var currentElement = values.first
  var sliceAfter = values.base.dropFirst()
  while !sliceAfter.isEmpty {
    let duplicatedElementsIndices = sliceAfter.indices(where: { nextElement in
      ErrorInfoFuncs.isApproximatelyEqualAny(currentElement, nextElement)
    })
    sliceAfter.removeSubranges(duplicatedElementsIndices) // ?? use DiscontiguousSlice<[T]>
    if let nextElement = sliceAfter.first {
      currentElement = nextElement
      sliceAfter = sliceAfter.dropFirst()
    }
  }
  processed.append(contentsOf: sliceAfter)
  return values
}

/// ```
/// let set1: Set = [1, 2, 3, 4, 5]
/// let set2: Set = [3, 4, 5, 6]
/// let set3: Set = [4, 5, 7, 8]
///
/// findCommonElements(inAnyOf: [set1, set2, set3])
/// // Output: [3, 4, 5]
/// // because 3 appears in 2 sets, 4 and 5 appear in all 3
/// ```
func findCommonElements<T: Hashable>(inAnyOf sets: [Set<T>]) -> Set<T> {
  var frequency: [T: Int] = [:]
  
//  do {
//    let totalCount = sets.reduce(into: 0) { count, set in
//      count += set.count
//    }
//    frequency.reserveCapacity(totalCount)
//  }
  
  for set in sets {
    for element in set {
      frequency[element, default: 0] += 1
    }
  }
  
  var common: Set<T> = []
  for (element, count) in frequency where count > 1 {
    common.insert(element)
  }
  return common
}

//let interErrorsCollidedKeys = mutate(value: Set<Key>()) { commonKeys in
//  var countedKeys: [Key: Int] = [:]
//  
//  for (errorIndex, error) in errors.enumerated() {
//    for key in error.info.keys {
//      countedKeys[key, default: 0] += 1
//    }
//  }
//  
//  for (key, count) in countedKeys where count > 1 {
//    commonKeys.insert(key)
//  }
//}

// let interErrorsCollidedKeys = mutate(value: Set<String>()) {
//  var slice = errors.base[...]
//  var sliceAfter = slice.dropFirst()
//  while !sliceAfter.isEmpty, let currentError = slice.first {
//    let currentKeys = currentError.info.keys.apply(Set.init)
//
//    for nextError in sliceAfter {
//      let intersetion = currentKeys.intersection(nextError.info.keys)
//      $0.formUnion(intersetion)
//    }
//
//    slice = sliceAfter
//    sliceAfter = slice.dropFirst()
//  }
// }
