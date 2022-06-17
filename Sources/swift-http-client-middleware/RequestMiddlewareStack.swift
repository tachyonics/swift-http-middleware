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

public struct RequestMiddlewareStack<HttpRequestType: HttpRequestProtocol,
                                     StackOutput,
                                     StackError> {
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var buildPhase: BuildPhase<HttpRequestType, StackOutput>
    public var finalizePhase: FinalizePhase<HttpRequestType, StackOutput>
    
    public init(id: String) {
        self.id = id
        self.buildPhase = BuildPhase<HttpRequestType, StackOutput>(id: BuildPhaseId)
        self.finalizePhase = FinalizePhase<HttpRequestType, StackOutput>(id: FinalizePhaseId)        
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware<HandlerType: HandlerProtocol>(
                                             input: HttpRequestBuilder<HttpRequestType>,
                                             next: HandlerType) async throws -> StackOutput
    where HandlerType.Input == HttpRequestBuilder<HttpRequestType>,
          HandlerType.Output == StackOutput {
              
              let finalize = compose(next: FinalizePhaseHandler(handler: next), with: finalizePhase)
              let build = compose(next: BuildPhaseHandler(handler: finalize), with: buildPhase)
              
              return try await build.handle(input: input)
          }
    
    mutating public func presignedRequest<HandlerType: HandlerProtocol>(
                                                      input: HttpRequestBuilder<HttpRequestType>,
                                                      next: HandlerType) async throws -> HttpRequestBuilder<HttpRequestType>
    where HandlerType.Input == HttpRequestBuilder<HttpRequestType>,
          HandlerType.Output == StackOutput {
        _ = try await handleMiddleware(input: input, next: next)
        return input
    }

    /// Compose (wrap) the handler with the given middleware or essentially build out the linked list of middleware
    private func compose<HandlerType: HandlerProtocol, MiddlewareType: MiddlewareProtocol>(
        next handler: HandlerType,
        with middlewares: MiddlewareType...) -> AnyHandler<HandlerType.Input, HandlerType.Output>
    where MiddlewareType.MOutput == HandlerType.Output,
          MiddlewareType.MInput == HandlerType.Input {
        guard !middlewares.isEmpty,
              let lastMiddleware = middlewares.last else {
            return handler.eraseToAnyHandler()
        }
        
        let numberOfMiddlewares = middlewares.count
        var composedHandler = ComposedHandler(handler, lastMiddleware)
        
        guard numberOfMiddlewares > 1 else {
            return composedHandler.eraseToAnyHandler()
        }
        let reversedCollection = (0...(numberOfMiddlewares - 2)).reversed()
        for index in reversedCollection {
            composedHandler = ComposedHandler(composedHandler, middlewares[index])
        }
        
        return composedHandler.eraseToAnyHandler()
    }
}
