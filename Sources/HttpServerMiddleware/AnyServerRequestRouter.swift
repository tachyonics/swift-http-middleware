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
//  AnyServerRouter.swift
//  HttpServerRequestRouter
//

import HttpMiddleware

#if compiler(<5.7)
/// type erase the ServerRequestRouter protocol
public struct AnyServerRouter<HTTPRequestType: HttpServerRequestProtocol,
                                     HTTPResponseType: HttpServerResponseProtocol>: ServerRouterProtocol {
    
    private let _select: (HTTPRequestType) async throws -> AnyHandler<HTTPRequestType, HttpServerResponseBuilder<HTTPResponseType>>

    public init<ServerRequestRouterType: ServerRouterProtocol>(_ realServerRequestRouter: ServerRequestRouterType)
    where ServerRequestRouterType.HTTPRequestType == HTTPRequestType, ServerRequestRouterType.HTTPResponseType == HTTPResponseType {
        if let alreadyErased = realServerRequestRouter as? AnyServerRouter {
            self = alreadyErased
            return
        }

        self._select = realServerRequestRouter.select
    }

    public func select(httpRequestType: HTTPRequestType) async throws -> AnyHandler<HTTPRequestType, HttpServerResponseBuilder<HTTPResponseType>> {
        return try await self._select(httpRequestType)
    }
}
#else
public typealias AnyServerRouter<MInput, MOutput> = any ServerRouterProtocol<MInput, MOutput>
#endif
