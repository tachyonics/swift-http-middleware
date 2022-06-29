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
//  RequestMiddlewareStack.swift
//  swift-http-client-middleware
//

public let BuildPhaseId = "Build"
public let FinalizePhaseId = "Finalize"

public struct RequestMiddlewareStack<HTTPRequestType: HttpRequestProtocol, HTTPResponseType: HttpResponseProtocol> {
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var buildPhase: RequestMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    public var finalizePhase: RequestMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    
    public init(id: String) {
        self.id = id
        self.buildPhase = RequestMiddlewarePhase(id: BuildPhaseId)
        self.finalizePhase = RequestMiddlewarePhase(id: FinalizePhaseId)        
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware<HandlerType: HandlerProtocol>(
                                             input: HttpRequestBuilder<HTTPRequestType>,
                                             next: HandlerType) async throws -> HTTPResponseType
    where HandlerType.Input == HttpRequestBuilder<HTTPRequestType>, HandlerType.Output == HTTPResponseType {
        let finalize = finalizePhase.compose(next: next)
        let build = buildPhase.compose(next: finalize)
              
        return try await build.handle(input: input)
    }
    
    mutating public func presignedRequest<HandlerType: HandlerProtocol>(
                                                      input: HttpRequestBuilder<HTTPRequestType>,
                                                      next: HandlerType) async throws -> HttpRequestBuilder<HTTPRequestType>
    where HandlerType.Input == HttpRequestBuilder<HTTPRequestType>,
          HandlerType.Output == HTTPResponseType {
        _ = try await handleMiddleware(input: input, next: next)
        return input
    }
}
