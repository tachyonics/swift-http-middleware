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
//  ServerRequestMiddlewareStack.swift
//  HttpServerMiddleware
//

import SwiftMiddleware

public struct ServerRequestMiddlewareStack<MiddlewareType: MiddlewareProtocol,
                                           HandlerType: MiddlewareHandlerProtocol,
                                           UnknownErrorHandlerType: UnknownErrorHandlerProtocol>: Sendable
where MiddlewareType.InputType: HttpServerRequestProtocol, MiddlewareType.OutputType: HttpServerResponseProtocol,
HandlerType.InputType == MiddlewareType.InputType,
HandlerType.OutputType == MiddlewareType.OutputType,
UnknownErrorHandlerType.HTTPRequestType == MiddlewareType.InputType,
UnknownErrorHandlerType.HTTPResponseType == MiddlewareType.OutputType,
UnknownErrorHandlerType.ContextType == MiddlewareContext {
    private let unknownErrorHandlerType: UnknownErrorHandlerType
    private let handler: ComposedMiddlewarePhaseHandler<MiddlewareType.InputType,
                                                        MiddlewareType.OutputType, MiddlewareType, HandlerType>
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    
    public init<MiddlewarePhaseType: MiddlewarePhaseProtocol>(
        id: String,
        unknownErrorHandlerType: UnknownErrorHandlerType,
        phase: MiddlewarePhaseType)
    where MiddlewarePhaseType.InputType == MiddlewareType.InputType,
    MiddlewarePhaseType.OutputType == MiddlewareType.OutputType,
    MiddlewarePhaseType.MiddlewareType == MiddlewareType,
    MiddlewarePhaseType.HandlerType == HandlerType {
        self.id = id
        self.handler = ComposedMiddlewarePhaseHandler(next: phase.next, with: phase.with)
        self.unknownErrorHandlerType = unknownErrorHandlerType
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware(input: MiddlewareType.InputType,
                                 context: MiddlewareContext) async -> MiddlewareType.OutputType {
        do {
            return try await self.handler.handle(input: input, context: context)
        } catch {
            return self.unknownErrorHandlerType.handle(request: input, error: error, context: context)
        }
    }
}

