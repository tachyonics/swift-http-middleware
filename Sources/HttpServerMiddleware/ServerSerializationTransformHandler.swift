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
//  ServerSerializationTransformHandler.swift
//  HttpServerMiddleware
//

import SwiftMiddleware
import HttpMiddleware

public struct ServerSerializationTransformHandler<InputType, OutputType, HTTPRequestType: HttpServerRequestProtocol,
                                                  HTTPResponseBuilderType: HttpServerResponseBuilderProtocol,
                                                  HandlerType: MiddlewareHandlerProtocol,
                                                  DeserializationTransformType: DeserializationTransformProtocol>: MiddlewareHandlerProtocol
where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType,
DeserializationTransformType.InputType == HTTPRequestType, DeserializationTransformType.OutputType == InputType,
DeserializationTransformType.ContextType == MiddlewareContext {

    public typealias Input = HTTPRequestType
    
    public typealias Output = SerializeServerResponseMiddlewarePhaseOutput<OutputType, HTTPResponseBuilderType>
    
    let handler: HandlerType
    let deserializationTransform: DeserializationTransformType
    
    public init(handler: HandlerType,
                deserializationTransform: DeserializationTransformType,
                responseBuilderType: HTTPResponseBuilderType.Type) {
        self.handler = handler
        self.deserializationTransform = deserializationTransform
    }
    
    public func handle(input: HTTPRequestType, context: MiddlewareContext) async throws -> Output {
        let deserializationOutput = try await self.deserializationTransform.transform(input: input, context: context)
        
        let serializationPhaseInput = try await handler.handle(input: deserializationOutput, context: context)
        
        return SerializeServerResponseMiddlewarePhaseOutput<OutputType, HTTPResponseBuilderType>(operationResponse: serializationPhaseInput)
    }
}
