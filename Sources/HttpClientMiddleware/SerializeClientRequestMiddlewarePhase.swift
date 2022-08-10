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
//  SerializeClientRequestMiddlewarePhase.swift
//  HttpClientMiddleware
//
/*
import HttpMiddleware

public let SerializeClientRequestPhaseId = "SerializeClientRequest"

public typealias SerializeClientRequestMiddlewarePhase<InputType,
                                               HTTPRequestType: HttpClientRequestProtocol,
                                               HTTPResponseType: HttpClientResponseProtocol>
    = MiddlewarePhase<SerializeClientRequestMiddlewarePhaseInput<InputType, HTTPRequestType>, HTTPResponseType>

public struct SerializeInputPhaseHandler<InputType,
                                         HTTPRequestType: HttpClientRequestProtocol,
                                         HTTPResponseType: HttpClientResponseProtocol,
                                         HandlerType: MiddlewareHandlerProtocol>: MiddlewareHandlerProtocol
where HandlerType.InputType == HttpClientRequestBuilder<HTTPRequestType>, HandlerType.OutputType == HTTPResponseType {
    
    public typealias InputType = SerializeClientRequestMiddlewarePhaseInput<InputType, HTTPRequestType>
    
    public typealias OutputType = HTTPResponseType
    
    let handler: HandlerType
    
    public init(handler: HandlerType) {
        self.handler = handler
    }
    
    public func handle(input: SerializeClientRequestMiddlewarePhaseInput<InputType, HTTPRequestType>, context: MiddlewareContext) async throws -> OutputType {
        return try await handler.handle(input: input.builder, context: context)
    }
}*/
