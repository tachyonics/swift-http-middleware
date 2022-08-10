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
//  FinalizeServerResponsePhaseHandler.swift
//  HttpServerMiddleware
//

import SwiftMiddleware

public struct FinalizeServerResponsePhaseHandler<HTTPRequestType: HttpServerRequestProtocol,
                                                 HTTPResponseType: HttpServerResponseProtocol,
                                                 HandlerType: MiddlewareHandlerProtocol>: MiddlewareHandlerProtocol
where HandlerType.InputType == HTTPRequestType, HandlerType.OutputType: HttpServerResponseBuilderProtocol,
HandlerType.OutputType.HTTPResponseType == HTTPResponseType {
    
    public typealias InputType = HTTPRequestType
    
    public typealias OutputType = HTTPResponseType
    
    let handler: HandlerType
    
    public init(handler: HandlerType) {
        self.handler = handler
    }
    
    public func handle(input: InputType, context: MiddlewareContext) async throws -> OutputType {
        let builder = try await handler.handle(input: input, context: context)
        
        return try builder.build()
    }
}
