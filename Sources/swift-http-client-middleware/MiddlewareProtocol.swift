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
//  MiddlewareProtocol.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
public protocol MiddlewareProtocol {
    associatedtype MInput
    associatedtype MOutput
    
    /// The middleware ID
    var id: String { get }
    
    func handle<H: HandlerProtocol>(input: MInput,
                                    next: H) async throws -> MOutput
    where H.Input == MInput, H.Output == MOutput
}

extension MiddlewareProtocol {
    public func eraseToAnyMiddleware() -> AnyMiddleware<MInput, MOutput> {
        return AnyMiddleware(self)
    }
}
#else
public protocol MiddlewareProtocol<MInput, MOutput> {
    associatedtype MInput
    associatedtype MOutput
    
    /// The middleware ID
    var id: String { get }
    
    func handle<H: HandlerProtocol>(input: MInput,
                                    next: H) async throws -> MOutput
    where H.Input == MInput, H.Output == MOutput
}

extension MiddlewareProtocol {
    public func eraseToAnyMiddleware() -> any MiddlewareProtocol<MInput, MOutput> {
        return self
    }
}
#endif
