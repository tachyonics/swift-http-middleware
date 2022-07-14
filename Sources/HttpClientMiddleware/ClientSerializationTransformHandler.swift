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
//  ClientSerializationTransformHandler.swift
//  HttpClientMiddleware
//

import HttpMiddleware

public struct ClientSerializationTransformHandler<InputType, OutputType, HTTPRequestType: HttpClientRequestProtocol,
                                                  HTTPResponseType: HttpClientResponseProtocol, HandlerType: MiddlewareHandlerProtocol>: MiddlewareHandlerProtocol
where HandlerType.InputType == SerializeClientRequestMiddlewarePhaseInput<InputType, HTTPRequestType>, HandlerType.OutputType == HTTPResponseType {

    public typealias Input = InputType
    
    public typealias Output = OutputType
    
    let handler: HandlerType
    let deserializationTransform: AnyDeserializationTransform<HTTPResponseType, OutputType, MiddlewareContext>
    
    public init<DeserializationTransformType: DeserializationTransformProtocol>(
                handler: HandlerType,
                deserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.InputType == HTTPResponseType, DeserializationTransformType.OutputType == OutputType,
    DeserializationTransformType.ContextType == MiddlewareContext {
        self.handler = handler
        self.deserializationTransform = deserializationTransform.eraseToAnyDeserializationTransform()
    }
    
    public func handle(input: InputType, context: MiddlewareContext) async throws -> Output {
        let serializationInput = SerializeClientRequestMiddlewarePhaseInput<InputType, HTTPRequestType>(input: input)
        
        let httpResponse = try await handler.handle(input: serializationInput, context: context)
        return try await self.deserializationTransform.transform(input: httpResponse, context: context)
    }
}
