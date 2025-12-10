//
//  OperationOtput.swift
//  ErrorInfo
//
//  Created by Dmitriy Ignatyev on 26/11/2025.
//

extension ErrorInfo {
  // e.g. is there collision when merging or converting to dictionary. If yes, what are these collisions?
  
  enum CollisionsResult {
    case noCollisions
    case collisions([Info])
    
    struct Info {
      let key: KeyWithOrigin
      let values: [CollisionTaggedValue<TypedNilOptional, CollisionSource>]
    }
  }
}
