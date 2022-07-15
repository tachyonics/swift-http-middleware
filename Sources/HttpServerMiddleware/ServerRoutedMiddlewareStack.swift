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
    public var router: AnyServerRouter<HTTPRequestType, RouterOutputHTTPRequestType, HTTPResponseType, MiddlewareContext>
    private var unknownErrorHandlerType: AnyUnknownErrorHandler<HTTPRequestType, HTTPResponseType, MiddlewareContext>
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var buildPhase: BuildServerResponseMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    public var finalizePhase: FinalizeServerResponseMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    
    public init<ServerRequestRouterType: ServerRouterProtocol,
                UnknownErrorHandlerType: UnknownErrorHandlerProtocol>(
                    id: String,
                    router: ServerRequestRouterType,
                    unknownErrorHandlerType: UnknownErrorHandlerType)
    where ServerRequestRouterType.InputHTTPRequestType == HTTPRequestType, ServerRequestRouterType.OutputHTTPRequestType == RouterOutputHTTPRequestType,
    ServerRequestRouterType.HTTPResponseType == HTTPResponseType, ServerRequestRouterType.ContextType == MiddlewareContext,
    UnknownErrorHandlerType.HTTPRequestType == HTTPRequestType,
    UnknownErrorHandlerType.HTTPResponseType == HTTPResponseType, UnknownErrorHandlerType.ContextType == MiddlewareContext {
        self.id = id
        self.buildPhase = BuildServerResponseMiddlewarePhase(id: BuildServerResponsePhaseId)
        self.finalizePhase = FinalizeServerResponseMiddlewarePhase(id: FinalizeServerResponsePhaseId)
        self.router = router.eraseToAnyServerRouter()
        self.unknownErrorHandlerType = unknownErrorHandlerType.eraseToAnyUnknownErrorHandler()
    }
    
    public mutating func replacingRouter<ServerRequestRouterType: ServerRouterProtocol>(
        router: ServerRequestRouterType)
    where ServerRequestRouterType.InputHTTPRequestType == HTTPRequestType, ServerRequestRouterType.OutputHTTPRequestType == RouterOutputHTTPRequestType,
    ServerRequestRouterType.HTTPResponseType == HTTPResponseType, ServerRequestRouterType.ContextType == MiddlewareContext {
        self.router = router.eraseToAnyServerRouter()
    }
    
    public mutating func replacingUnknownErrorHandler<UnknownErrorHandlerType: UnknownErrorHandlerProtocol>(
        unknownErrorHandlerType: UnknownErrorHandlerType)
    where UnknownErrorHandlerType.HTTPRequestType == HTTPRequestType,
    UnknownErrorHandlerType.HTTPResponseType == HTTPResponseType, UnknownErrorHandlerType.ContextType == MiddlewareContext {
        self.unknownErrorHandlerType = unknownErrorHandlerType.eraseToAnyUnknownErrorHandler()
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware(input: HTTPRequestType, context: MiddlewareContext) async -> HTTPResponseType {
        let build = buildPhase.compose(next: BuildServerResponsePhaseHandler(router: self.router))
        let finalize = finalizePhase.compose(next: FinalizeServerResponsePhaseHandler(handler: build))
        
        do {
            return try await finalize.handle(input: input, context: context)
        } catch {
            return self.unknownErrorHandlerType.handle(request: input, error: error, context: context)
        }
    }
}
