//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

#if !COLLECTIONS_SINGLE_MODULE
import ContainersPreview
#endif

#if compiler(>=6.2) && COLLECTIONS_UNSTABLE_NONCOPYABLE_KEYS

@available(SwiftStdlib 5.0, *)
extension UniqueDictionary where Key: ~Copyable, Value: ~Copyable {
  @inlinable
  @discardableResult
  public mutating func insertValue(
    _ value: consuming Value,
    forKey key: consuming Key
  ) -> Value? {
    fatalError("Unimplemented")
  }
  
  @inlinable
  @discardableResult
  public mutating func updateValue(
    _ value: consuming Value,
    forKey key: consuming Key
  ) -> Value? {
    fatalError("Unimplemented")
  }
  
#if COLLECTIONS_UNSTABLE_CONTAINERS_PREVIEW
  @inlinable
  @discardableResult
  @_lifetime(&self)
  public mutating func memoizedValue(
    forKey key: consuming Key,
    _ body: (borrowing Key) -> Value
  ) -> Borrow<Value> {
    fatalError("Unimplemented")
  }
#endif
}

#endif
