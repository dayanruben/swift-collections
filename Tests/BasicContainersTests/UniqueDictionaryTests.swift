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

import XCTest
#if COLLECTIONS_SINGLE_MODULE
import Collections
#else
import _CollectionsTestSupport
import BasicContainers
#endif


class UniqueDictionaryTests: CollectionTestCase {
  func test_withKeys() {
    typealias Key = LifetimeTracked<Int>
    typealias Value = LifetimeTracked<String>
    withEvery("capacity", in: [0, 1, 2, 10, 100, 1000]) { capacity in
      withLifetimeTracking { tracker in
        var d = RigidDictionary<Key, Value>(capacity: capacity)
        withEvery("i", in: 0 ..< capacity) { i in
          let key = tracker.instance(for: i)
          let value = tracker.instance(for: "\(i)")
          d.insertValue(value, forKey: key)
          
          d.withKeys { keys in
            expectEqual(keys.count, i + 1)
            expectEqual(keys.capacity, capacity)
#if COLLECTIONS_UNSTABLE_CONTAINERS_PREVIEW
            var it = keys.makeBorrowingIterator()
            var actual: Set<Int> = []
            while true {
              let next = it.nextSpan()
              guard !next.isEmpty else { break }
              for i in next.indices {
                expectTrue(
                  actual.insert(next[i].payload).inserted,
                  "Duplicate value \(next[i].payload)")
              }
            }
            expectEqualElements(actual.sorted(), 0 ... i)
#else
            for j in 0 ... i {
              expectTrue(keys.contains(tracker.instance(for: j)))
            }
#endif
          }
        }
      }
    }
  }
}
