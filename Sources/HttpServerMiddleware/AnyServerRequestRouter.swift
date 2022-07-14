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
//  AnyServerRouter.swift
//  HttpServerRequestRouter
//

import HttpMiddleware

#if compiler(<5.7)
/// type erase the ServerRequestRouter protocol
public struct AnyServerRouter<InputHTTPRequestType: HttpServerRequestProtocol,
                              OutputHTTPRequestType: HttpServerRequestProtocol,
                              HTTPResponseType: HttpServerResponseProtocol,
                              ContextType>: ServerRouterProtocol {
    
    private let _select: (InputHTTPRequestType, ContextType) async throws -> ServerRouterOutput<OutputHTTPRequestType, HTTPResponseType>

    public init<ServerRequestRouterType: ServerRouterProtocol>(_ realServerRequestRouter: ServerRequestRouterType)
    where ServerRequestRouterType.InputHTTPRequestType == InputHTTPRequestType, ServerRequestRouterType.OutputHTTPRequestType == OutputHTTPRequestType,
    ServerRequestRouterType.HTTPResponseType == HTTPResponseType, ServerRequestRouterType.ContextType == ContextType {
        if let alreadyErased = realServerRequestRouter as? AnyServerRouter {
            self = alreadyErased
            return
        }

        self._select = realServerRequestRouter.select
    }

    public func select(httpRequest: InputHTTPRequestType, context: ContextType) async throws -> ServerRouterOutput<OutputHTTPRequestType, HTTPResponseType> {
        return try await self._select(httpRequest, context)
    }
}
#else
public typealias AnyServerRouter<InputHTTPRequestType, OutputHTTPRequestType, HTTPResponseType>
    = any ServerRouterProtocol<InputHTTPRequestType, OutputHTTPRequestType, HTTPResponseType>
#endif
