//
//  Merge+SummaryInfoTests.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 19/12/2025.
//

@testable import ErrorInfo
import Testing

struct `Merge+SummaryInfoTests` {
  // MARK: - _determinePrefix
  
  @Test func determinePrefix_noPrefix() {
    let prefix = Merge._Summary._determinePrefix(keysPrefixOption: .noPrefix,
                                                 infoSource: "source1",
                                                 infoSourceIndex: 0,
                                                 elementIndex: 0)
      
    #expect(prefix == nil)
  }
    
  @Test func determinePrefix_withCustomPrefix() {
    let keysPrefixOption: Merge.Format.KeysPrefixOption<String> =
      .customPrefix(boundaryDelimiter: .onlySpacer(":"),
                    keyPrefixBuilder: { sourceSignature, si, _ in "\(si)_" + sourceSignature })
    let prefix = Merge._Summary._determinePrefix(keysPrefixOption: keysPrefixOption,
                                                 infoSource: "NSURL9",
                                                 infoSourceIndex: 0,
                                                 elementIndex: 1)
    #expect(prefix == "0_NSURL9:")
  }
    
  // MARK: - _makePrefixString
  
  @Test func makePrefixString_onlySpacer() {
    let result = Merge._Summary._makePrefixString(("prefix", .onlySpacer(".")))
    #expect(result == "prefix.")
  }
    
  @Test func makePrefixString_withEnclosure() {
    let result = Merge._Summary._makePrefixString(("prefix", .enclosure(spacer: " ", opening: "[", closing: "]")))
    #expect(result == "[prefix] ")
  }
    
  // MARK: - _determineKeyOrigin
  
  @Test func determineKeyOrigin_availableKeyOrigin() {
    let record = (key: "key1", value: KeyOrigin.dynamic)
    
    let keyOriginAvailability: Merge.KeyOriginAvailability<(key: String, value: KeyOrigin)> =
      .available(keyPath: \.value, interpolation: { $0.defaultInterpolation() })
      
    let origin = Merge._Summary._determineKeyOrigin(element: record,
                                                    keyOriginAvailability: keyOriginAvailability,
                                                    keyHasCollisionAcross: true,
                                                    keyHasCollisionWithin: false,
                                                    annotationsFormat: .default)
    // TODO: - annotationsFormat is too large dependency.
    // check all combinations
    #expect(origin == "dynamic") // Expecting the key origin annotation
  }
    
  @Test func determineKeyOrigin_noKeyOrigin() {
    let record = (key: "key1", value: KeyOrigin.dynamic)
    
    let keyOriginAvailability: Merge.KeyOriginAvailability<(key: String, value: KeyOrigin)> = .notAvailable
      
    let origin = Merge._Summary._determineKeyOrigin(
      element: record,
      keyOriginAvailability: keyOriginAvailability,
      keyHasCollisionAcross: false,
      keyHasCollisionWithin: false,
      annotationsFormat: .default,
    )
      
    #expect(origin == nil) // Expecting nil when no key origin is available
  }
  
  // MARK: - _determineCollisionSource
    
  @Test func determineCollisionSource_availableCollisionSource() {
    let record = (key: "value", value: .onCreateWithDictionaryLiteral as WriteProvenance?)
    
    let collisionAvailability: Merge.CollisionAvailability<(key: String, value: WriteProvenance?)> =
      .available(keyPath: \.value, interpolation: { $0.defaultStringInterpolation() })
      
    let collisionSource = Merge._Summary._determineCollisionSource(collisionAvailability: collisionAvailability,
                                                                   element: record)
      
    #expect(collisionSource == "onCreateWithDictionaryLiteral") // Expecting the collision source annotation
  }
  
  @Test func determineCollisionSource_NilCollisionSource() {
    let record = (key: "value", value: nil as WriteProvenance?)
    
    let collisionAvailability: Merge.CollisionAvailability<(key: String, value: WriteProvenance?)> =
      .available(keyPath: \.value, interpolation: { $0.defaultStringInterpolation() })
      
    let collisionSource = Merge._Summary._determineCollisionSource(collisionAvailability: collisionAvailability,
                                                                   element: record)
      
    #expect(collisionSource == nil)
  }
    
  @Test func determineCollisionSource_noCollisionSource() {
    let element = (key: "key1", value: 1)
    let collisionAvailability: Merge.CollisionAvailability<(key: String, value: Int)> = .notAvailable
      
    let collisionSource = Merge._Summary._determineCollisionSource(collisionAvailability: collisionAvailability,
                                                                   element: element)
      
    #expect(collisionSource == nil) // Expecting nil when .notAvailable
  }
  
  // MARK: -  _appendSuffixAnnotations
    
  @Test func appendSuffixAnnotations_allNil() {
    var result = "key1"
    Merge._Summary._appendSuffixAnnotations(
      keyOrigin: nil,
      collisionSource: nil,
      errorInfoSignature: nil,
      annotationsFormat: .default,
      to: &result,
    )
      
    #expect(result == "key1") // No annotations should be added when all are nil
  }
    
  @Test func appendSuffixAnnotations_withAllComponents() {
    var result = "key1"
    Merge._Summary._appendSuffixAnnotations(keyOrigin: "literal",
                                            collisionSource: "onMerge",
                                            errorInfoSignature: "signature",
                                            annotationsFormat: .default,
                                            to: &result)
    
    #expect(result == "key1 (keyOrigin: literal, collision: onMerge, sourceSignature: signature)")
  }
    
  // MARK: - _findDuplicateElements
  
  @Test func findDuplicateElements_noDuplicates() {
    let collections = [
      Set([1, 2, 3]),
      Set([4, 5, 6]),
      Set([7, 8, 9]),
    ]
      
    let result = Merge._Summary._findDuplicateElements(in: collections)
    #expect(result.duplicatesAcrossSources.isEmpty)
    #expect(result.duplicatesWithinSources.allSatisfy { $0.isEmpty })
  }
    
  @Test func findDuplicateElements_withDuplicatesAcrossSources() {
    let collections = [
      [1, 2, 3, 22],
      [3, 4, 6, 22],
      [5, 3, 2, 7],
    ]
      
    let result = Merge._Summary._findDuplicateElements(in: collections)
    #expect(result.duplicatesWithinSources.allSatisfy { $0.isEmpty })
    #expect(result.duplicatesWithinSources.count == collections.count)
    
    #expect(result.duplicatesAcrossSources.count == 3)
    #expect(result.duplicatesAcrossSources.contains(2))
    #expect(result.duplicatesAcrossSources.contains(22))
    #expect(result.duplicatesAcrossSources.contains(3))
  }
    
  @Test func findDuplicateElements_withDuplicatesWithinSources() {
    let collections = [
      [2, 2, 3],
      [4, 8],
      [5, 5, 6, 7, 7],
    ]
      
    let result = Merge._Summary._findDuplicateElements(in: collections)
    
    #expect(result.duplicatesAcrossSources.isEmpty)
    #expect(result.duplicatesWithinSources.count == collections.count)
    
    #expect(result.duplicatesWithinSources[0].count == 1)
    #expect(result.duplicatesWithinSources[0].contains(2))
    
    #expect(result.duplicatesWithinSources[1].isEmpty)
    
    #expect(result.duplicatesWithinSources[2].count == 2)
    #expect(result.duplicatesWithinSources[2].contains(5))
    #expect(result.duplicatesWithinSources[2].contains(7))
  }
  
  // MARK: - _generateUniqueSignatures
    
  @Test func generateUniqueSignatures_noDuplicates() {
    let sources = ["sourceA", "sourceB", "sourceC"]
    let uniqueSignatures = Merge._Summary._generateUniqueSignatures(forInfoProviders: sources) { $0 }
      
    #expect(uniqueSignatures == ["sourceA", "sourceB", "sourceC"])
  }
    
  @Test func generateUniqueSignatures_withDuplicates() {
    let sources = ["sourceA", "sourceB", "sourceA"]
    let uniqueSignatures = Merge._Summary._generateUniqueSignatures(forInfoProviders: sources) { $0 }
      
    #expect(uniqueSignatures == ["sourceA(0)", "sourceB", "sourceA(2)"])
  }
  
  // MARK: - _makeIndexedSignature
  
  @Test func makeIndexedSignature() {
    let signature = Merge._Summary._makeIndexedSignature(rawSignature: "NSURL6", index: 3)
    #expect(signature == "NSURL6(3)") // Expecting indexed signature format
  }
}
