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
//  ServerRouterProtocol.swift
//  HttpServerMiddleware
//

import SwiftMiddleware

public protocol ServerRouterOutputProtocol<InputType, OutputType> {
    associatedtype InputType: HttpServerRequestProtocol
    associatedtype OutputType: HttpServerResponseBuilderProtocol
    associatedtype HandlerType: MiddlewareHandlerProtocol<InputType, OutputType, MiddlewareContext>
    
    var httpRequest: HandlerType.InputType { get }
    var handler: HandlerType { get }
}

public struct ServerRouterOutput<HandlerType: MiddlewareHandlerProtocol>: ServerRouterOutputProtocol
where HandlerType.InputType: HttpServerRequestProtocol,
      HandlerType.OutputType: HttpServerResponseBuilderProtocol {
    public typealias InputType = HandlerType.InputType
    public typealias OutputType = HandlerType.OutputType
    
    public let httpRequest: HandlerType.InputType
    public let handler: HandlerType
    
    public init(httpRequest: HandlerType.InputType,
                handler: HandlerType) {
        self.httpRequest = httpRequest
        self.handler = handler
    }
}

public protocol ServerRouterProtocol: Sendable {
    associatedtype InputHTTPRequestType: HttpServerRequestProtocol
    associatedtype OutputHTTPRequestType: HttpServerRequestProtocol
    associatedtype HTTPResponseType: HttpServerResponseProtocol
    
    @Sendable
    func select(
        httpRequest: InputHTTPRequestType,
        context: MiddlewareContext) async throws -> any ServerRouterOutputProtocol<OutputHTTPRequestType, HTTPResponseType>
}
