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

import HttpMiddleware

public struct ServerRequestMiddlewareStack<HTTPRequestType: HttpServerRequestProtocol, HTTPResponseType: HttpServerResponseProtocol> {
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var buildPhase: BuildServerResponseMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    public var finalizePhase: FinalizeServerResponseMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    
    public init(id: String) {
        self.id = id
        self.buildPhase = BuildServerResponseMiddlewarePhase(id: BuildServerResponsePhaseId)
        self.finalizePhase = FinalizeServerResponseMiddlewarePhase(id: FinalizeServerResponsePhaseId)
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware<HandlerType: MiddlewareHandlerProtocol>(
                                             input: HTTPRequestType,
                                             context: MiddlewareContext,
                                             next: HandlerType) async throws -> HTTPResponseType
    where HandlerType.InputType == HTTPRequestType, HandlerType.OutputType == HttpServerResponseBuilder<HTTPResponseType> {
        let build = buildPhase.compose(next: next)
        let finalize = finalizePhase.compose(next: FinalizeServerResponsePhaseHandler(handler: build))
              
        return try await finalize.handle(input: input, context: context)
    }
}
