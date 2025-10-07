//
//  ErrorInfo+ConvenienceSubscript.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 07/10/2025.
//

extension ErrorInfo {
  // MARK: With Custom TypeInfoOptions
  public mutating func withCustomTypeInfoOptions(_ options: TypeInfoOptions,
                                                 append: (consuming CustomTypeInfoOptionsView) -> Void) {
    withUnsafeMutablePointer(to: &self) { pointer in
      let view = CustomTypeInfoOptionsView(pointer: pointer)
      append(view)
    }
  }
  
  public struct CustomTypeInfoOptionsView: ~Copyable { // ~Escapable
    private let pointer: UnsafeMutablePointer<ErrorInfo>
    
    fileprivate init(pointer: UnsafeMutablePointer<ErrorInfo>) {
      self.pointer = pointer
    }
    
    public subscript(key: Key, omitEqualValue: Bool = true) -> (any ValueType)? {
      @available(*, unavailable, message: "This is a set-only subscript. To get values for key use `allValues(forKey:)` function")
      get { pointer.pointee.allValues(forKey: key)?.first.value }
      set {
        let value: any ValueType = if let newValue {
          newValue
        } else {
          "nil"
        }
        pointer.pointee._add(key: key, value: value, omitEqualValue: omitEqualValue, collisionSource: .onSubscript)
      }
    }
  }
}
