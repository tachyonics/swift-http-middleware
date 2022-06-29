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
//  OperationMiddlewareStack.swift
//  swift-http-client-middleware
//

public struct OperationMiddlewareStack<StackInput,
                                       HttpRequestType: HttpRequestProtocol,
                                       HTTPResponseType, StackOutput> {
    private var serializationTransform:
        AnyTransform<SerializationTransformInput<StackInput, HttpRequestType>, HttpRequestBuilder<HttpRequestType>>
    private var deserializationTransform:
        AnyTransform<HTTPResponseType, StackOutput>
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var initializePhase: InitializePhase<StackInput, StackOutput, HTTPResponseType>
    public var buildPhase: BuildPhase<HttpRequestType, OperationOutput<StackOutput, HTTPResponseType>>
    public var finalizePhase: FinalizePhase<HttpRequestType, OperationOutput<StackOutput, HTTPResponseType>>
    public var secondFinalizePhase: SecondFinalizePhase<HttpRequestType, HTTPResponseType>
    
    public init<SerializationTransformType: TransformProtocol, DeserializationTransformType: TransformProtocol>(
        id: String, serializationTransform: SerializationTransformType, deserializationTransform: DeserializationTransformType)
    where SerializationTransformType.TInput == SerializationTransformInput<StackInput, HttpRequestType>,
          SerializationTransformType.TOutput == HttpRequestBuilder<HttpRequestType>,
          DeserializationTransformType.TInput == HTTPResponseType,
          DeserializationTransformType.TOutput == StackOutput
    {
        self.id = id
        self.initializePhase = InitializePhase(id: InitializePhaseId)
        self.buildPhase = BuildPhase(id: BuildPhaseId)
        self.finalizePhase = FinalizePhase(id: FinalizePhaseId)
        self.secondFinalizePhase = SecondFinalizePhase(id: SecondFinalizePhaseId)
        self.serializationTransform = serializationTransform.eraseToAnyTransform()
        self.deserializationTransform = deserializationTransform.eraseToAnyTransform()
    }
    
    public mutating func replace<SerializationTransformType: TransformProtocol>(serializationTransform: SerializationTransformType)
    where SerializationTransformType.TInput == SerializationTransformInput<StackInput, HttpRequestType>,
          SerializationTransformType.TOutput == HttpRequestBuilder<HttpRequestType>
    {
        self.serializationTransform = serializationTransform.eraseToAnyTransform()
    }
    
    public mutating func replace<DeserializationTransformType: TransformProtocol>(deserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.TInput == HTTPResponseType,
          DeserializationTransformType.TOutput == StackOutput
    {
        self.deserializationTransform = deserializationTransform.eraseToAnyTransform()
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware<HandlerType: HandlerProtocol>(
                                             input: StackInput,
                                             next: HandlerType) async throws -> StackOutput
    where HandlerType.Input == HttpRequestBuilder<HttpRequestType>, HandlerType.Output == HTTPResponseType {
        let secondFinalize = compose(next: SecondFinalizePhaseHandler(handler: next), with: secondFinalizePhase)
        let deserialise = DeserializationTransformHandler(handler: secondFinalize, deserializationTransform: self.deserializationTransform)
        let finalize = compose(next: FinalizePhaseHandler(handler: deserialise), with: finalizePhase)
        let build = compose(next: BuildPhaseHandler(handler: finalize), with: buildPhase)
        let serialize = SerializationTransformHandler(serializationTransform: self.serializationTransform, handler: build)
        let initialize = compose(next: InitializePhaseHandler(handler: serialize), with: initializePhase)
              
        return try await initialize.handle(input: input).output
    }
    
    mutating public func presignedRequest<HandlerType: HandlerProtocol>(
                                                      input: StackInput,
                                                      next: HandlerType) async throws -> StackInput
    where HandlerType.Input == HttpRequestBuilder<HttpRequestType>,
          HandlerType.Output == HTTPResponseType {
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
