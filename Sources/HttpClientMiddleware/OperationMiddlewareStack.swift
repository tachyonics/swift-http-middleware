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
    public var _serializationTransform: AnySerializationTransform<InputType, HTTPRequestType>
    public var _deserializationTransform: AnyDeserializationTransform<HTTPResponseType, OutputType>
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var initializePhase: OperationMiddlewarePhase<InputType, OutputType>
    public var buildPhase: RequestMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    public var finalizePhase: RequestMiddlewarePhase<HTTPRequestType, HTTPResponseType>
    
    public init<SerializationTransformType: SerializationTransformProtocol, DeserializationTransformType: DeserializationTransformProtocol>(
        id: String, serializationTransform: SerializationTransformType, deserializationTransform: DeserializationTransformType)
    where SerializationTransformType.InputType == InputType, SerializationTransformType.HTTPRequestType == HTTPRequestType,
          DeserializationTransformType.HTTPResponseType == HTTPResponseType, DeserializationTransformType.OutputType == OutputType {
        self.id = id
        self.initializePhase = OperationMiddlewarePhase(id: InitializePhaseId)
        self.buildPhase = RequestMiddlewarePhase(id: BuildPhaseId)
        self.finalizePhase = RequestMiddlewarePhase(id: FinalizePhaseId)
        self._serializationTransform = serializationTransform.eraseToAnySerializationTransform()
        self._deserializationTransform = deserializationTransform.eraseToAnyDeserializationTransform()
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware<HandlerType: HandlerProtocol>(input: InputType,
                                                               next: HandlerType) async throws -> OutputType
    where HandlerType.InputType == HttpRequestBuilder<HTTPRequestType>, HandlerType.OutputType == HTTPResponseType {
        let finalize = finalizePhase.compose(next: next)
        let build = buildPhase.compose(next: finalize)
        let serialize = SerializationTransformHandler(serializationTransform: self._serializationTransform,
                                                      handler: build,
                                                      deserializationTransform: self._deserializationTransform)
        let initialize = initializePhase.compose(next: serialize)
              
        return try await initialize.handle(input: input)
    }
    
    mutating public func presignedRequest<HandlerType: HandlerProtocol>(input: InputType,
                                                                        next: HandlerType) async throws -> InputType
    where HandlerType.InputType == HttpRequestBuilder<HTTPRequestType>, HandlerType.OutputType == HTTPResponseType {
        _ = try await handleMiddleware(input: input, next: next)
        return input
    }
}
