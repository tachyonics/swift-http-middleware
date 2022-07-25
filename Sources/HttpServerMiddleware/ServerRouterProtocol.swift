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
//  ServerRouterProtocol.swift
//  HttpServerMiddleware
//

import HttpMiddleware

public struct ServerRouterOutput<HTTPRequestType: HttpServerRequestProtocol,
                                 HTTPResponseType: HttpServerResponseProtocol> {
    public let httpRequest: HTTPRequestType
    public let handler: AnyMiddlewareHandler<HTTPRequestType, HttpServerResponseBuilder<HTTPResponseType>>
    
    public init(httpRequest: HTTPRequestType,
                handler: AnyMiddlewareHandler<HTTPRequestType, HttpServerResponseBuilder<HTTPResponseType>>) {
        self.httpRequest = httpRequest
        self.handler = handler
    }
}

#if compiler(<5.7)
public protocol ServerRouterProtocol {
    associatedtype InputHTTPRequestType: HttpServerRequestProtocol
    associatedtype OutputHTTPRequestType: HttpServerRequestProtocol
    associatedtype HTTPResponseType: HttpServerResponseProtocol
    associatedtype ContextType
    
    @Sendable
    func select(
        httpRequest: InputHTTPRequestType,
        context: ContextType) async throws -> ServerRouterOutput<OutputHTTPRequestType, HTTPResponseType>
}

extension ServerRouterProtocol {
    public func eraseToAnyServerRouter() -> AnyServerRouter<InputHTTPRequestType, OutputHTTPRequestType, HTTPResponseType, ContextType> {
        return AnyServerRouter(self)
    }
}
#else
public protocol ServerRouterProtocol {
    associatedtype HTTPResponseType: HttpClientResponseProtocol
    associatedtype OutputType
    
    @Sendable
    func select(
        httpRequest: HTTPRequestType) async throws -> AnyHandler<HTTPRequestType, HTTPResponseType>
}

extension ServerRouterProtocol {
    public func eraseToAnyServerRouter() -> any AnyServerRouter<HTTPResponseType, OutputType> {
        return self
    }
}
#endif
