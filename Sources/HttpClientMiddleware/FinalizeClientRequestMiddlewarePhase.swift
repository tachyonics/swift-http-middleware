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
//  FinalizeClientRequestMiddlewarePhase.swift
//  HttpClientMiddleware
//
/*
import HttpMiddleware

public let FinalizeClientRequestPhaseId = "FinalizeClientRequest"

public typealias FinalizeClientRequestMiddlewarePhase<HTTPRequestType: HttpClientRequestProtocol,
                                                      HTTPResponseType: HttpClientResponseProtocol>
    = MiddlewarePhase<HTTPRequestType, HTTPResponseType>

public struct FinalizeClientRequestPhaseHandler<HTTPRequestType: HttpClientRequestProtocol,
                                                HTTPResponseType: HttpClientResponseProtocol,
                                                HandlerType: MiddlewareHandlerProtocol>: MiddlewareHandlerProtocol
where HandlerType.InputType == HTTPRequestType, HandlerType.OutputType == HTTPResponseType {
    
    public typealias InputType = HttpClientRequestBuilder<HTTPRequestType>
    
    public typealias OutputType = HTTPResponseType
    
    let handler: HandlerType
    
    public init(handler: HandlerType) {
        self.handler = handler
    }
    
    public func handle(input: InputType, context: MiddlewareContext) async throws -> OutputType {
        return try await handler.handle(input: input.build(), context: context)
    }
}
*/
