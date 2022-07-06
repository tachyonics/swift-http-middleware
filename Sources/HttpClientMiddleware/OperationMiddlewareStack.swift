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

public let InitializePhaseId = "Initialize"

public struct OperationMiddlewareStack<InputType, OutputType, HTTPRequestType: HttpRequestProtocol,
                                       HTTPResponseType: HttpResponseProtocol> {
    public var _deserializationTransform: AnyDeserializationTransform<HTTPResponseType, OutputType>
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var initializePhase: OperationMiddlewarePhase<InputType, OutputType>
    public var serializeInputPhase: SerializeInputMiddlewarePhase<InputType, HTTPRequestType, HTTPResponseType>
    public var buildPhase: BuildRequestMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    public var finalizePhase: FinalizeRequestMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    
    public init<DeserializationTransformType: DeserializationTransformProtocol>(
        id: String, deserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.HTTPResponseType == HTTPResponseType, DeserializationTransformType.OutputType == OutputType {
        self.id = id
        self.initializePhase = OperationMiddlewarePhase(id: InitializePhaseId)
        self.buildPhase = BuildRequestMiddlewarePhase(id: BuildPhaseId)
        self.finalizePhase = FinalizeRequestMiddlewarePhase(id: FinalizePhaseId)
        self.serializeInputPhase = SerializeInputMiddlewarePhase(id: SerializeInputPhaseId)
        self._deserializationTransform = deserializationTransform.eraseToAnyDeserializationTransform()
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware<HandlerType: HandlerProtocol>(input: InputType,
                                                               next: HandlerType) async throws -> OutputType
    where HandlerType.InputType == HTTPRequestType, HandlerType.OutputType == HTTPResponseType {
        let finalize = finalizePhase.compose(next: next)
        let build = buildPhase.compose(next: FinalizePhaseHandler(handler: finalize))
        let serializeInput = serializeInputPhase.compose(next: SerializeInputPhaseHandler(handler: build))
        let transform = SerializationTransformHandler(handler: serializeInput,
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
