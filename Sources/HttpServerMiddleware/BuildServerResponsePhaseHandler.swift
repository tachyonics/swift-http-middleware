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
//  BuildServerResponseMiddlewarePhase.swift
//  HttpServerMiddleware
//

import SwiftMiddleware

public struct BuildServerResponsePhaseHandler<ServerRouterType: ServerRouterProtocol>: MiddlewareHandlerProtocol {
    
    public typealias InputType = ServerRouterType.InputHTTPRequestType
    
    public typealias OutputType = ServerRouterType.HTTPResponseType
    
    let router: ServerRouterType
    
    public init(router: ServerRouterType) {
        self.router = router
    }
    
    public func handle(input: InputType, context: MiddlewareContext) async throws -> OutputType {
        let routerOutput: any ServerRouterOutputProtocol<ServerRouterType.OutputHTTPRequestType, ServerRouterType.HTTPResponseType>
            = try await self.router.select(httpRequest: input, context: context)
        let handler: any MiddlewareHandlerProtocol<ServerRouterType.OutputHTTPRequestType, ServerRouterType.HTTPResponseType, MiddlewareContext>
            = routerOutput.handler // Type of expression is ambiguous without more context
            // Inferred result type 'any MiddlewareHandlerProtocol' requires explicit coercion due to loss of generic requirements
            as! any MiddlewareHandlerProtocol<ServerRouterType.OutputHTTPRequestType, ServerRouterType.HTTPResponseType, MiddlewareContext>
        
         return try await handler.handle(input: routerOutput.httpRequest, context: context)
    }
}
