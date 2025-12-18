//
//  Merge+Format.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 05/12/2025.
//

public import struct OrderedCollections.OrderedSet

/// A namespace for key-annotation formatting used by  `summaryInfo` merge func.
/// Configure ordering, naming, and delimiters of annotations appended to keys,
/// and policies that decide when to include origin metadata.
extension Merge.Format {
  /// Describes how to render the suffix annotations for a key.
  /// Controls the order of components, whether names are shown, and how the block attaches to the key.
  ///
  /// Example (default):
  /// ```swift
  /// "someKey (keyOrigin: literal, collision: onMerge(file_line: Main.swift:31), sourceSignature: NSCocoa.17)"
  /// ```
  public struct KeyAnnotationsFormat: Sendable {
    /// The order in which annotation components appear.
    internal let annotationsOrder: OrderedSet<AnnotationComponentKind>
    /// Delimiters used to join components and attach the annotations block to the key.
    internal let annotationsDelimiters: AnnotationsBlockDelimiters
    
    /// Policy that determines when to include key-origin details (unique vs. collision).
    internal let keyOriginPolicy: KeyOriginAnnotationPolicy
    
    /// Controls whether component names are emitted and how they are formatted.
    internal let annotationNameOption: AnnotationNameOption
    
    /// Creates a key-annotation format.
    /// - Parameters:
    ///   - annotationsOrder: The order for components like origin, collision, and signature.
    ///   - annotationsDelimiters: How components are separated and attached to the key.
    ///   - keyOriginPolicy: When to include origin details for unique keys vs. collisions.
    ///   - annotationNameOption: Whether and how to display component names.
    public init(annotationsOrder: OrderedSet<AnnotationComponentKind>,
                annotationsDelimiters: AnnotationsBlockDelimiters,
                keyOriginPolicy: KeyOriginAnnotationPolicy,
                annotationNameOption: AnnotationNameOption) {
      self.annotationsOrder = annotationsOrder
      self.annotationsDelimiters = annotationsDelimiters
      self.keyOriginPolicy = keyOriginPolicy
      self.annotationNameOption = annotationNameOption
    }
    
    /// Default format: order = [keyOrigin, collisionSource, errorInfoSignature],
    /// comma-separated, enclosed in parentheses, names included.
    public static let `default` = KeyAnnotationsFormat(annotationsOrder: AnnotationComponentKind.defaultOrdering,
                                                       annotationsDelimiters: .default,
                                                       keyOriginPolicy: .default,
                                                       annotationNameOption: .default)
  }
  
  /// Components that can be appended to a key as annotations.
  public enum AnnotationComponentKind: Sendable, Hashable, CaseIterable {
    /// Where the key came from (literal, key path, dynamic, modified).
    case keyOrigin
    /// What caused a collision and where (e.g., onMerge(fileLine: …)).
    case collisionSource
    /// A compact signature of the info source (e.g., subsystem.code).
    case errorInfoSignature
    // case typeOfValue
    
    /// Default display name for the component.
    public var defaultName: String {
      switch self {
      case .keyOrigin: "keyOrigin"
      case .collisionSource: "collision"
      case .errorInfoSignature: "sourceSignature"
      }
    }
    
    /// Standard ordering used by the default format.
    public static let defaultOrdering: OrderedSet<Self> = [.keyOrigin, .collisionSource, .errorInfoSignature]
  }
  
  /// Controls whether component names are rendered before values.
  public enum AnnotationNameOption: Sendable {
    /// Render values only (no component names).
    case noNames
    /// Render `name` then `separator` then value; `nameForComponent` supplies the per-component name.
    case withNames(separator: String, nameForComponent: @Sendable (AnnotationComponentKind) -> String)
    
    /// Default: names included with ": ", using each component's default name.
    /// Example: "someKey (keyOrigin: literal, collision: onMerge(fileLine: Main.swift:31), sourceSignature: NSCocoa.17)"
    public static let `default`: AnnotationNameOption = .withNames(separator: ": ",
                                                                   nameForComponent: { $0.defaultName })
  }
  
  /// Optional prefix to place before each key when summarizing multiple sources.
  public enum KeysPrefixOption<InfoSource>: Sendable {
    /// Do not add any prefix.
    case noPrefix

    /// Attach a custom per-key prefix.
    /// - Parameters:
    ///   - boundaryDelimiter: How to attach the prefix (spacer-only or enclosure).
    ///   - keyPrefixBuilder: Builds the prefix string from (source, sourceIndex, keyIndex).
    /// Example result: "[err0] someKey" or "err0 | someKey".
    case customPrefix(boundaryDelimiter: AnnotationsBoundaryDelimiter,
                      keyPrefixBuilder: @Sendable (_ infoSource: InfoSource, _ sourceIndex: Int, _ keyIndex: Int) -> String)
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Key Origin

extension Merge.Format {
  /// Determines when key-origin details are included for unique keys and for collisions.
  public struct KeyOriginAnnotationPolicy: Sendable {
    /// Options applied when the key is unique (no collision).
    public var whenUnique: KeyOriginOptions
    /// Options applied when the key collides (across or within sources).
    public var whenCollision: KeyOriginOptions

    /// Initializes a key-origin annotation policy.
    /// - Parameters:
    ///   - whenUnique: Options to apply for unique keys.
    ///   - whenCollision: Options to apply for colliding keys.
    public init(whenUnique: KeyOriginOptions,
                whenCollision: KeyOriginOptions) {
      self.whenUnique = whenUnique
      self.whenCollision = whenCollision
    }

    /// Default: omit origin for unique keys; include all origins on collision.
    public static let `default` = KeyOriginAnnotationPolicy(whenUnique: [], whenCollision: .allOrigins)
    
    /// Never include origin details.
    public static let neverAdd = KeyOriginAnnotationPolicy(whenUnique: [], whenCollision: [])
  }
  
  /// Bitmask of origin kinds that may be rendered.
  public struct KeyOriginOptions: OptionSet, Sendable {
    public let rawValue: UInt8
    
    public init(rawValue: UInt8) {
      self.rawValue = rawValue
    }
    
    /// Keys created from literals or combined literals.
    public static let literal = Self(rawValue: 1 << 0)
    
    /// Keys derived from a key path.
    public static let keyPath = Self(rawValue: 1 << 1)
    
    /// Keys built dynamically at runtime.
    public static let dynamic = Self(rawValue: 1 << 2)
    
    /// Keys mapped or modified after creation.
    public static let modified = Self(rawValue: 1 << 3)
    
    /// Convenience that enables all origin kinds.
    public static let allOrigins: Self = [.literal, .keyPath, .dynamic, .modified]
    
    /// Returns true if this option set contains the given origin kind.
    @inlinable internal func matches(keyOrigin: KeyOrigin) -> Bool {
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
  /// Controls how components are joined and how the block is attached to the key.
  public struct AnnotationsBlockDelimiters: Sendable {
    /// Separator between components (e.g., ", " or "; ").
    internal let componentsSeparator: String
    /// How the block is attached to the key (spacer-only or enclosure).
    internal let blockBoundary: AnnotationsBoundaryDelimiter
    
    /// Initializes delimiters for annotation blocks.
    /// - Parameters:
    ///   - componentsSeparator: How multiple components are joined into one string.
    ///   - blockBoundary: How the entire block is attached to the key.
    public init(componentsSeparator: String, blockBoundary: AnnotationsBoundaryDelimiter) {
      self.componentsSeparator = componentsSeparator
      self.blockBoundary = blockBoundary
    }
    
    /// Default: comma separator, enclosed in parentheses.
    public static let `default` = Self(componentsSeparator: ", ", blockBoundary: .parentheses)
  }
  
  /// How the annotations block is visually attached to the key.
  ///
  /// # Example:
  ///
  /// **Spacer-only form:**
  ///
  /// "key | origin, collision"
  ///
  /// "key • origin, collision"
  ///
  /// **Enclosure form:**
  ///
  /// "key (origin, collision)"
  ///
  /// "key [origin, collision]"
  public enum AnnotationsBoundaryDelimiter: Sendable {
    /// Attach using only a spacer (e.g., " | ").
    case onlySpacer(spacer: String)
    /// Attach using a spacer and enclosing characters (e.g., ( … ), [ … ]).
    case enclosure(spacer: String, opening: Character, closing: Character)
        
    /// " | " spacer.
    static let verticalBar: Self = .onlySpacer(spacer: " | ")
    
    /// Space plus parentheses enclosure.
    static let parentheses: Self = .enclosure(spacer: " ", opening: "(", closing: ")")
  }
}

// ===-------------------------------------------------------------------------------------------------------------------=== //

// MARK: - Nil

extension Merge.Format {
  /// How to render `nil` values within summaries.
  public enum NilFormat {
    /// Render as `nil`.
    case literal
    /// Render as `nil` plus a type hint enclosed with the given delimiters (e.g., `nil (String?)`).
    case literalWithType(delimiters: AnnotationsBoundaryDelimiter)
  }
}
