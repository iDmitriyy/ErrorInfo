//
//  ErrorInfo+Views.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 27/10/2025.
//

public import protocol InternalCollectionsUtilities._UniqueCollection

extension ErrorInfo {
  public var uniqueKeys: some Collection<String> & _UniqueCollection {
    _storage.uniqueKeys
  }
}

extension ErrorInfo {
  struct ValuesWithMetaDataView {
    
  }
  
  struct NonNilValuesView {
    
  }
  
  struct WithNilValuesView {
    
  }
}
