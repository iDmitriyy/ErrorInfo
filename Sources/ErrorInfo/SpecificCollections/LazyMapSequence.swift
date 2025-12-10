//
//  LazyMapSequence.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 10/12/2025.
//

/// Allows iteration over a `Collection`, transforming its elements using a projection closure during iteration.
/// It can be useful when you need to work with a collection of transformed elements, without modifying
/// the original collection or allocating new buffer for transformed elements.
