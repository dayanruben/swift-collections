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
import ContainersPreview
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
  
  func test_removeValueForKey_one() {
    typealias Key = LifetimeTracked<Int>
    typealias Value = LifetimeTracked<String>
    withEvery("minCap", in: [1, 2, 10, 100, 200]) { minCap in
      withEvery("count", in: [1, minCap / 3, minCap / 2, 2 * minCap / 3, minCap - 1, minCap] as Set) { count in
        guard count > 0 else { return }
        withSome("key", in: 0 ..< count) { key in
          withLifetimeTracking { tracker in
            var d = UniqueDictionary<Key, Value>(minimumCapacity: minCap)
            for i in 0 ..< count {
              let key = tracker.instance(for: i)
              let value = tracker.instance(for: "\(i)")
              d.insertValue(value, forKey: key)
            }
            
            let oldValue = d.removeValue(forKey: tracker.instance(for: key))
            expectNotNil(oldValue) {
              expectEqual($0.payload, "\(key)")
            }
            expectEqual(d.count, count - 1)
            
            for i in 0 ..< count {
              let value = d.withValue(forKey: tracker.instance(for: i)) { $0 }
              if i == key {
                expectNil(value)
              } else {
                expectEqual(value?.payload, "\(i)")
              }
            }
          }
        }
      }
    }
  }
  
  func test_removeValueForKey_all() {
    typealias Key = LifetimeTracked<Int>
    typealias Value = LifetimeTracked<String>
    withEvery("minCap", in: [1, 2, 10, 100, 200]) { minCap in
      withLifetimeTracking { tracker in
        var d = UniqueDictionary<Key, Value>(minimumCapacity: minCap)
        let capacity = d.capacity
        for i in 0 ..< d.capacity {
          let key = tracker.instance(for: i)
          let value = tracker.instance(for: "\(i)")
          d.insertValue(value, forKey: key)
        }
        expectEqual(d.capacity, capacity)

        withEvery("key", in: 0 ..< d.capacity) { key in
          let oldValue = d.removeValue(forKey: tracker.instance(for: key))
          expectNotNil(oldValue) {
            expectEqual($0.payload, "\(key)")
          }
          expectEqual(d.count, capacity - key - 1)
        }
        expectEqual(d.count, 0)
      }
    }
  }

}
