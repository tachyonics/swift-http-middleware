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
//  HttpHeadersProtocol.swift
//  swift-http-client-middleware
//

public protocol HttpHeadersProtocol: Equatable {
    
    /// Creates an instance from a `[String: [String]]`.
    init(_ dictionary: [String: [String]])

    /// Case-insensitively updates or appends a `Header` into the instance using the provided `name` and `value`.
    ///
    /// - Parameters:
    ///   - name:  The `String` name.
    ///   - value: The `String` value.
    mutating func add(name: String, value: String)
    
    /// Case-insensitively updates the value of a `Header` by appending the new values to it or appends a `Header`
    /// into the instance using the provided `name` and `values`.
    ///
    /// - Parameters:
    ///   - name:  The `String` name.
    ///   - values: The `[String]` values.
    mutating func add(name: String, values: [String])
    
    /// Case-insensitively updates the value of a `Header` by replacing the values of it or appends a `Header`
    /// into the instance if it does not exist using the provided `Header`.
    ///
    /// - Parameters:
    ///   - header:  The `Header` to be added or updated.
    mutating func replaceOrAdd(name: String, values: [String])
    
    /// Case-insensitively updates the value of a `Header` by replacing the values of it or appends a `Header`
    /// into the instance if it does not exist using the provided `Header`.
    ///
    /// - Parameters:
    ///   - header:  The `Header` to be added or updated.
    mutating func replaceOrAdd(name: String, value: String)
    
    /// Case-insensitively adds all `Headers` into the instance using the provided `[Headers]` array.
    ///
    /// - Parameters:
    ///   - headers:  The `Headers` object.
    mutating func add(contentsOf: Self)

    /// Case-insensitively removes a `Header`, if it exists, from the instance.
    ///
    /// - Parameter name: The name of the `HTTPHeader` to remove.
    mutating func remove(name: String)
    
    /// Case-insensitively find a header's values by name.
    ///
    /// - Parameter name: The name of the header to search for, case-insensitively.
    ///
    /// - Returns: The values of the header, if they exist.
    subscript(name: String) -> [String] { get }
}

public extension HttpHeadersProtocol {
    init(_ dictionary: [String: String]) {
        var expandedDictionary: [String: [String]] = [:]
        dictionary.forEach { (key, value) in
            expandedDictionary[key] = [value]
        }
        
        self.init(expandedDictionary)
    }
}
