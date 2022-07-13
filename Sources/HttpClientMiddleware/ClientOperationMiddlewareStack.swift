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
//  ClientOperationMiddlewareStack.swift
//  HttpClientMiddleware
//

import HttpMiddleware

public let InitializePhaseId = "Initialize"

public struct ClientOperationMiddlewareStack<InputType, OutputType, HTTPRequestType: HttpClientRequestProtocol,
                                             HTTPResponseType: HttpClientResponseProtocol> {
    public var _deserializationTransform: AnyDeserializationTransform<HTTPResponseType, OutputType>
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var initializePhase: OperationMiddlewarePhase<InputType, OutputType>
    public var serializePhase: SerializeClientRequestMiddlewarePhase<InputType, HTTPRequestType, HTTPResponseType>
    public var buildPhase: BuildClientRequestMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    public var finalizePhase: FinalizeClientRequestMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    
    public init<DeserializationTransformType: DeserializationTransformProtocol>(
        id: String, deserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.InputType == HTTPResponseType, DeserializationTransformType.OutputType == OutputType {
        self.id = id
        self.initializePhase = OperationMiddlewarePhase(id: InitializePhaseId)
        self.buildPhase = BuildClientRequestMiddlewarePhase(id: BuildClientRequestPhaseId)
        self.finalizePhase = FinalizeClientRequestMiddlewarePhase(id: FinalizeClientRequestPhaseId)
        self.serializePhase = SerializeClientRequestMiddlewarePhase(id: SerializeClientRequestPhaseId)
        self._deserializationTransform = deserializationTransform.eraseToAnyDeserializationTransform()
    }
    
    public mutating func replacingDeserializationTransform<DeserializationTransformType: DeserializationTransformProtocol>(
        deserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.InputType == HTTPResponseType, DeserializationTransformType.OutputType == OutputType {
        self._deserializationTransform = deserializationTransform.eraseToAnyDeserializationTransform()
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware<HandlerType: HandlerProtocol>(input: InputType,
                                                               next: HandlerType) async throws -> OutputType
    where HandlerType.InputType == HTTPRequestType, HandlerType.OutputType == HTTPResponseType {
        let finalize = finalizePhase.compose(next: next)
        let build = buildPhase.compose(next: FinalizeClientRequestPhaseHandler(handler: finalize))
        let serializeInput = serializePhase.compose(next: SerializeInputPhaseHandler(handler: build))
        let transform = ClientSerializationTransformHandler(handler: serializeInput,
                                                            deserializationTransform: self._deserializationTransform)
        let initialize = initializePhase.compose(next: transform)
              
        return try await initialize.handle(input: input)
    }
    
    mutating public func presignedRequest<HandlerType: HandlerProtocol>(input: InputType,
                                                                        next: HandlerType) async throws -> InputType
    where HandlerType.InputType == HTTPRequestType, HandlerType.OutputType == HTTPResponseType {
        _ = try await handleMiddleware(input: input, next: next)
        return input
    }
}
