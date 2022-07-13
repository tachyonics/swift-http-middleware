// Copyright 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//
//  OrderedGroup.swift
//  HttpMiddleware
//

struct RelativeOrder {
    var order: [String] = []
    
    mutating func add(position: AbsolutePosition, ids: String...) {
        if ids.isEmpty { return}
        var unDuplicatedList = ids
        for index in  0...(ids.count - 1) {
            let id = ids[index]
            if order.contains(id) {
                // if order already has the id, remove it from the list so it is not re-inserted
                unDuplicatedList.remove(at: index)
            }
        }
        
        switch position {
        case .end:
            order.append(contentsOf: unDuplicatedList)
        case .start:
            order.insert(contentsOf: unDuplicatedList, at: 0)
        }
    }
    
    mutating func insert(relativeTo: String, position: RelativePosition, ids: String...) {
        if ids.isEmpty {return}
        let indexOfRelativeItem = order.firstIndex(of: relativeTo)
        if let indexOfRelativeItem = indexOfRelativeItem {
            switch position {
            case .before:
                order.insert(contentsOf: ids, at: indexOfRelativeItem - 1)
            case .after:
                order.insert(contentsOf: ids, at: indexOfRelativeItem)
            }
    
        }
    }
    
    func has(id: String) -> Bool {
       return order.contains(id)
    }
    
    mutating func clear() {
        order.removeAll()
    }
}

public struct OrderedGroup<MiddlewareType: MiddlewareProtocol> {
    // order of the keys
    var order = RelativeOrder()
    // key here is name of the middleware aka the id property of the middleware
    private var _items: [String: MiddlewareType] = [:]
    
    var orderedItems: [(key: String, value: MiddlewareType)] {
        
        var sorted = [(key: String, value: MiddlewareType)]()
        for key in order.order {
            guard let value = _items[key] else {
                continue
            }
            let tuple = (key: key, value: value)
            sorted.append(tuple)
        }
        return sorted
    }
    
    public init() {}
    
    mutating func add(middleware: MiddlewareType,
                      position: AbsolutePosition) {
        if !middleware.id.isEmpty {
            _items[middleware.id] = middleware
            order.add(position: position, ids: middleware.id)
        }
    }
    
    mutating func insert(middleware: MiddlewareType,
                         relativeTo: String,
                         position: RelativePosition) {
        _items[middleware.id] = middleware
        order.insert(relativeTo: relativeTo, position: position, ids: middleware.id)
    }
    
    func get(id: String)-> MiddlewareType? {
        return _items[id]
    }
}
