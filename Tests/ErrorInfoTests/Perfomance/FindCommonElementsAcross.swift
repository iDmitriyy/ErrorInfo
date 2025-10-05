//
//  FindCommonElementsAcross.swift
//  ErrorInfo
//
//  Created Dmitriy Ignatyev on 04/10/2025.
//

@testable import ErrorInfo
import Testing

struct FindCommonElementsAcross {
  let set0: Set<String> = (0...500).map(String.init(describing:)).apply(Set.init)
  let set1: Set<String> = (450...550).map(String.init(describing:)).apply(Set.init)
  let set2: Set<String> = (450...1000).map(String.init(describing:)).apply(Set.init)
  let set3: Set<String> = (400...500).map(String.init(describing:)).apply(Set.init)
  let set4: Set<String> = (0...550).map(String.init(describing:)).apply(Set.init)
  
  @Test func findCommonElements_() {
    let output = performMeasuredAction(count: 100) {
      findCommonElements(across: [set0, set1, set2, set3, set4])
    }
    
    // 3.657 3.522 3.590
    print(output.duration)
  }
}
