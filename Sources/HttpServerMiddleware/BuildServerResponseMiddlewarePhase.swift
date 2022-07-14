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
//  BuildServerResponseMiddlewarePhase.swift
//  HttpServerMiddleware
//

import HttpMiddleware

public let BuildServerResponsePhaseId = "BuildServerResponse"

public typealias BuildServerResponseMiddlewarePhase<HTTPRequestType: HttpServerRequestProtocol,
                                                    HTTPResponseType: HttpServerResponseProtocol>
    = MiddlewarePhase<HTTPRequestType, HttpServerResponseBuilder<HTTPResponseType>>

public struct BuildServerResponsePhaseHandler<HTTPRequestType: HttpServerRequestProtocol,
                                              RouterOutputHTTPRequestType: HttpServerRequestProtocol,
                                              HTTPResponseType: HttpServerResponseProtocol>: MiddlewareHandlerProtocol {
    
    public typealias InputType = HTTPRequestType
    
    public typealias OutputType = HttpServerResponseBuilder<HTTPResponseType>
    
    let routerOutput: ServerRouterOutput<RouterOutputHTTPRequestType, HTTPResponseType>
    
    public init(routerOutput: ServerRouterOutput<RouterOutputHTTPRequestType, HTTPResponseType>) {
        self.routerOutput = routerOutput
    }
    
    public func handle(input: InputType, context: MiddlewareContext) async throws -> OutputType {
        return try await routerOutput.handler.handle(input: routerOutput.httpRequest, context: context)
    }
}
