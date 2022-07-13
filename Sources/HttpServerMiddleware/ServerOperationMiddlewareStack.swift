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
//  ServerOperationMiddlewareStack.swift
//  HttpServerMiddleware
//

import HttpMiddleware

public let InitializePhaseId = "Initialize"

public struct ServerOperationMiddlewareStack<InputType, OutputType, HTTPRequestType: HttpServerRequestProtocol,
                                             HTTPResponseType: HttpServerResponseProtocol> {
    public var _deserializationTransform: AnyDeserializationTransform<HTTPRequestType, InputType>
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var initializePhase: OperationMiddlewarePhase<InputType, OutputType>
    public var serializePhase: SerializeServerResponseMiddlewarePhase<OutputType, HTTPRequestType, HTTPResponseType>
    public var buildPhase: BuildServerResponseMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    public var finalizePhase: FinalizeServerResponseMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    
    public init<DeserializationTransformType: DeserializationTransformProtocol>(
        id: String, deserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.InputType == HTTPRequestType, DeserializationTransformType.OutputType == InputType {
        self.id = id
        self.initializePhase = OperationMiddlewarePhase(id: InitializePhaseId)
        self.buildPhase = BuildServerResponseMiddlewarePhase(id: BuildServerResponsePhaseId)
        self.finalizePhase = FinalizeServerResponseMiddlewarePhase(id: FinalizeServerResponsePhaseId)
        self.serializePhase = SerializeServerResponseMiddlewarePhase(id: SerializeServerResponsePhaseId)
        self._deserializationTransform = deserializationTransform.eraseToAnyDeserializationTransform()
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware<HandlerType: HandlerProtocol>(input: HTTPRequestType,
                                                               next: HandlerType) async throws -> HTTPResponseType
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        let initialize = initializePhase.compose(next: next)
        let transform = ServerSerializationTransformHandler<InputType, OutputType, HTTPRequestType, HTTPResponseType,
                                                                AnyHandler<HandlerType.InputType, HandlerType.OutputType>>(
            handler: initialize, deserializationTransform: self._deserializationTransform)
        let serializeInput = serializePhase.compose(next: transform)
        let build = buildPhase.compose(next: SerializeServerResponsePhaseHandler(handler: serializeInput))
        let finalize = finalizePhase.compose(next: FinalizeServerResponsePhaseHandler(handler: build))
        
        return try await finalize.handle(input: input)
    }
}
