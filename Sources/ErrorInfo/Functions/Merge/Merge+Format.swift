//
//  Merge+Format.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/12/2025.
//

public import struct OrderedCollections.OrderedSet

extension Merge {
  public enum Format {}
}

extension Merge.Format {
  public struct KeyAnnotationsFormat: Sendable {
    internal let annotationsOrder: OrderedSet<AnnotationComponentKind>
    internal let annotationsDelimiters: AnnotationsBlockDelimiters
    
    internal let keyOriginPolicy: KeyOriginAnnotationPolicy
    
    // TODO: - prependAllKeysWithErrorInfoSignature: Bool
    // - name for component
    
    public init(annotationsOrder: OrderedSet<AnnotationComponentKind>,
                annotationsDelimiters: AnnotationsBlockDelimiters,
                keyOriginPolicy: KeyOriginAnnotationPolicy) {
      self.annotationsOrder = annotationsOrder
      self.annotationsDelimiters = annotationsDelimiters
      self.keyOriginPolicy = keyOriginPolicy
    }
    
    public static let `default` = KeyAnnotationsFormat(annotationsOrder: AnnotationComponentKind.defaultOrdering,
                                                       annotationsDelimiters: .default,
                                                       keyOriginPolicy: .default)
  }
  
  /// In which order annotations will be added
  public enum AnnotationComponentKind: Sendable, Hashable, CaseIterable {
    case keyOrigin
    case collisionSource
    case errorInfoSignature
    // case typeOfValue
    
    public static let defaultOrdering: OrderedSet<Self> = [.keyOrigin, .collisionSource, .errorInfoSignature]
  }
  
  // TODO: By default annotations should be added with name for AnnotationComponentKind
  // userd_id (keyType: .literal, collision: onMerge(fileLine: MainScreen.Swift:31), sourceSignature: NSCocoa.17)
  
  public enum KeysPrefixOption<InfoSource> {
    case noPrefix
    case customPrefix(boundaryDelimiter: AnnotationsBoundaryDelimiter,
                      keyPrefixBuilder: (_ infoSource: InfoSource, _ sourceIndex: Int, _ keyIndex: Int) -> String)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Key Origin

extension Merge.Format {
  public struct KeyOriginAnnotationPolicy: Sendable {
    public var whenUnique: KeyOriginOptions
    public var whenCollision: KeyOriginOptions

    public init(whenUnique: KeyOriginOptions,
                whenCollision: KeyOriginOptions) {
      self.whenUnique = whenUnique
      self.whenCollision = whenCollision
    }

    public static let `default` = KeyOriginAnnotationPolicy(whenUnique: [], whenCollision: .allOrigins)
    
    public static let neverAdd = KeyOriginAnnotationPolicy(whenUnique: [], whenCollision: [])
  }
  
  public struct KeyOriginOptions: OptionSet, Sendable {
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
      self.rawValue = rawValue
    }
    
    public static let literal = Self(rawValue: 1 << 0)
    
    public static let keyPath = Self(rawValue: 1 << 1)
    
    public static let dynamic = Self(rawValue: 1 << 2)
    
    public static let modified = Self(rawValue: 1 << 3)
    
    public static let allOrigins: Self = [.literal, .keyPath, .dynamic, .modified]
    
    // Improvement: @inlineable
    internal func matches(keyOrigin: KeyOrigin) -> Bool {
      let mask: Self = switch keyOrigin {
      case .literalConstant, .combinedLiterals: .literal
      case .dynamic: .dynamic
      case .keyPath: .keyPath
      case .unverifiedMapped, .modified: .modified
      }
      return contains(mask)
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Delimiters

extension Merge.Format {
  /// Defines how the entire annotation block is visually attached..
  /// Examples:
  /// Spacer-only form:
  /// key | origin, collision
  /// key • origin, collision
  /// Enclosure form:
  /// key [origin, collision]
  /// key (origin, collision)
  public enum AnnotationsBoundaryDelimiter: Sendable {
    case onlySpacer(spacer: String)
    case enclosure(spacer: String, opening: Character, closing: Character)
        
    static let verticalBar: Self = .onlySpacer(spacer: " | ")
    
    static let parentheses: Self = .enclosure(spacer: " ", opening: "(", closing: ")")
  }
  
  public struct AnnotationsBlockDelimiters: Sendable {
    /// How multiple annotation components are joined
    /// Example: "origin, collision" or "origin | collision"
    internal let componentsSeparator: String
    /// How the entire block of these components is visually attached to the key, either:
    /// via simple spacing: "key | origin, collision"
    /// or via enclosure: "key [origin, collision]"
    internal let blockBoundary: AnnotationsBoundaryDelimiter
    
    public init(componentsSeparator: String, blockBoundary: AnnotationsBoundaryDelimiter) {
      self.componentsSeparator = componentsSeparator
      self.blockBoundary = blockBoundary
    }
    
    public static let `default` = Self(componentsSeparator: ", ", blockBoundary: .parentheses)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Nil

extension Merge.Format {
  public enum NilFormat {
    case literal
    case literalWithType(delimiters: AnnotationsBoundaryDelimiter)
  }
}
