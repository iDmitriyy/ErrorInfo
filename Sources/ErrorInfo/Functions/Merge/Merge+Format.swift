//
//  Merge+Format.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/12/2025.
//

public import struct OrderedCollections.OrderedSet

extension Merge {
  public struct KeyAnnotationsFormat: Sendable {
    internal let annotationsOrder: OrderedSet<AnnotationComponentKind>
    internal let annotationsDelimiters: AnnotationsBlockDelimiters
    
    internal let keyOriginPolicy: KeyOriginAnnotationPolicy
    internal let keyOriginInterpolation: @Sendable (KeyOrigin) -> String
    
    // TODO: - prependAllKeysWithErrorInfoSignature: Bool
    // - name for component
    
    public init(annotationsOrder: OrderedSet<AnnotationComponentKind>,
                annotationsDelimiters: AnnotationsBlockDelimiters,
                keyOriginPolicy: KeyOriginAnnotationPolicy,
                keyOriginInterpolation: @Sendable @escaping (KeyOrigin) -> String) {
      self.annotationsOrder = annotationsOrder
      self.annotationsDelimiters = annotationsDelimiters
      self.keyOriginPolicy = keyOriginPolicy
      self.keyOriginInterpolation = keyOriginInterpolation
    }
    
    public static let `default` = KeyAnnotationsFormat(annotationsOrder: AnnotationComponentKind.defaultOrdering,
                                                       annotationsDelimiters: .default,
                                                       keyOriginPolicy: .default,
                                                       keyOriginInterpolation: { $0.shortSignInterpolation() })
  }
  
  /// In which order annotations will be added
  public enum AnnotationComponentKind: Sendable, Hashable, CaseIterable {
    case keyOrigin
    case collisionSource
    case errorInfoSignature
    // case typeOfValue
    
    public static let defaultOrdering: OrderedSet<Self> = [.keyOrigin, .collisionSource, .errorInfoSignature]
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Key Origin

extension Merge {
  public struct KeyOriginAnnotationPolicy: Sendable {
    public var whenUnique: KeyOriginOptions
    public var whenCollision: KeyOriginOptions

    public init(whenUnique: KeyOriginOptions,
                whenCollision: KeyOriginOptions) {
      self.whenUnique = whenUnique
      self.whenCollision = whenCollision
    }

    public static let `default` = KeyOriginAnnotationPolicy(whenUnique: [],
                                                            whenCollision: .allOrigins)
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
    
    internal func _isSuitableFor(keyOrigin: KeyOrigin) -> Bool {
      switch keyOrigin {
      case .literalConstant, .combinedLiterals:
        contains(.literal)
      case .dynamic:
        contains(.dynamic)
      case .keyPath:
        contains(.keyPath)
      case .unverifiedMapped, .modified:
        contains(.modified)
      }
    }
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Delimiters

extension Merge {
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

extension Merge {
  public enum NilFormat {
    case literal
    case literalWithType(delimiters: AnnotationsBoundaryDelimiter)
  }
}
