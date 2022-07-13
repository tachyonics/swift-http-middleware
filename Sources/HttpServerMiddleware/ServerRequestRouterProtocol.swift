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
//  ServerRequestRouterProtocol.swift
//  HttpServerMiddleware
//

import HttpMiddleware

#if compiler(<5.7)
public protocol ServerRequestRouterProtocol {
    associatedtype HTTPRequestType: HttpServerRequestProtocol
    associatedtype HTTPResponseType: HttpServerResponseProtocol
    
    func select(
        httpRequestType: HTTPRequestType) async throws -> AnyHandler<HTTPRequestType, HttpServerResponseBuilder<HTTPResponseType>>
}

extension ServerRequestRouterProtocol {
    public func eraseToAnyServerRequestRouter() -> AnyServerRequestRouter<HTTPRequestType, HTTPResponseType> {
        return AnyServerRequestRouter(self)
    }
}
#else
public protocol ServerRequestRouterProtocol {
    associatedtype HTTPResponseType: HttpClientResponseProtocol
    associatedtype OutputType
    
    func select(
        httpRequestType: HTTPRequestType) async throws -> AnyHandler<HTTPRequestType, HTTPResponseType>
}

extension ServerRequestRouterProtocol {
    public func eraseToAnyServerRequestRouter() -> any AnyServerRequestRouter<HTTPResponseType, OutputType> {
        return self
    }
}
#endif
