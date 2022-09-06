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
//  SerializeServerResponseMiddlewarePhase.swift
//  HttpServerMiddleware
//

import SwiftMiddleware

public struct SerializeServerResponsePhaseHandler<OutputType,
                                                  HTTPRequestType: HttpServerRequestProtocol,
                                                  HTTPResponseBuilderType: HttpServerResponseBuilderProtocol,
                                                  HandlerType: MiddlewareHandlerProtocol>: MiddlewareHandlerProtocol
where HandlerType.InputType == HTTPRequestType,
      HandlerType.OutputType == SerializeServerResponseMiddlewarePhaseOutput<OutputType, HTTPResponseBuilderType> {
    
    public typealias InputType = HTTPRequestType
    
    public typealias OutputType = HTTPResponseBuilderType
    
    let handler: HandlerType
    
    public init(handler: HandlerType) {
        self.handler = handler
    }
    
    public func handle(input: HTTPRequestType, context: MiddlewareContext) async throws -> HTTPResponseBuilderType {
        let phaseOutput = try await handler.handle(input: input, context: context)
        
        return phaseOutput.builder
    }
}
