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
//  ServerRoutedMiddlewareStack.swift
//  HttpServerMiddleware
//

import HttpMiddleware

public struct ServerRoutedMiddlewareStack<HTTPRequestType: HttpServerRequestProtocol,
                                          RouterOutputHTTPRequestType: HttpServerRequestProtocol, HTTPResponseType: HttpServerResponseProtocol> {
    public var router: AnyServerRouter<HTTPRequestType, RouterOutputHTTPRequestType, HTTPResponseType>
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var buildPhase: BuildServerResponseMiddlewarePhase<RouterOutputHTTPRequestType, HTTPResponseType>
    public var finalizePhase: FinalizeServerResponseMiddlewarePhase<RouterOutputHTTPRequestType, HTTPResponseType>
    
    public init<ServerRequestRouterType: ServerRouterProtocol>(id: String,
                router: ServerRequestRouterType)
    where ServerRequestRouterType.InputHTTPRequestType == HTTPRequestType, ServerRequestRouterType.OutputHTTPRequestType == RouterOutputHTTPRequestType,
    ServerRequestRouterType.HTTPResponseType == HTTPResponseType {
        self.id = id
        self.buildPhase = BuildServerResponseMiddlewarePhase(id: BuildServerResponsePhaseId)
        self.finalizePhase = FinalizeServerResponseMiddlewarePhase(id: FinalizeServerResponsePhaseId)
        self.router = router.eraseToAnyServerRouter()
    }
    
    public mutating func replacingRouter<ServerRequestRouterType: ServerRouterProtocol>(
        router: ServerRequestRouterType)
    where ServerRequestRouterType.InputHTTPRequestType == HTTPRequestType, ServerRequestRouterType.OutputHTTPRequestType == RouterOutputHTTPRequestType,
    ServerRequestRouterType.HTTPResponseType == HTTPResponseType {
        self.router = router.eraseToAnyServerRouter()
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware(input: HTTPRequestType) async throws -> HTTPResponseType {
        let routerOutput = try await self.router.select(httpRequestType: input)
        let build = buildPhase.compose(next: routerOutput.handler)
        let finalize = finalizePhase.compose(next: FinalizeServerResponsePhaseHandler(handler: build))
              
        return try await finalize.handle(input: routerOutput.httpRequest)
    }
}
