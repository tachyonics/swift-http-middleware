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
//  SingleServerOperationMiddlewareStack.swift
//  HttpServerMiddleware
//

import HttpMiddleware

public let InitializePhaseId = "Initialize"

public struct SingleServerOperationMiddlewareStack<InputType, OutputType,
                                                   HTTPRequestType: HttpServerRequestProtocol, HTTPResponseType: HttpServerResponseProtocol> {
    public var _deserializationTransform: AnyDeserializationTransform<HTTPRequestType, InputType, MiddlewareContext>

    public var initializePhase: OperationMiddlewarePhase<InputType, OutputType>
    public var serializePhase: SerializeServerResponseMiddlewarePhase<OutputType, HTTPRequestType, HTTPResponseType>
    
    public init<DeserializationTransformType: DeserializationTransformProtocol>(
        id: String, deserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.InputType == HTTPRequestType, DeserializationTransformType.OutputType == InputType,
    DeserializationTransformType.ContextType == MiddlewareContext {
        self.initializePhase = OperationMiddlewarePhase(id: InitializePhaseId)
        self.serializePhase = SerializeServerResponseMiddlewarePhase(id: SerializeServerResponsePhaseId)
        self._deserializationTransform = deserializationTransform.eraseToAnyDeserializationTransform()
    }
    
    public mutating func replacingDeserializationTransform<DeserializationTransformType: DeserializationTransformProtocol>(
        deserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.InputType == HTTPRequestType, DeserializationTransformType.OutputType == InputType,
    DeserializationTransformType.ContextType == MiddlewareContext {
        self._deserializationTransform = deserializationTransform.eraseToAnyDeserializationTransform()
    }
}
