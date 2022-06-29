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
//  AnyRequestMiddleware.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
/// type erase the Middleware protocol
public struct AnyRequestMiddleware<HTTPRequestType: HttpRequestProtocol, HTTPResponseType: HttpResponseProtocol>: RequestMiddlewareProtocol {
    
    private let _handle: (HttpRequestBuilder<HTTPRequestType>,
                          AnyHandler<HttpRequestBuilder<HTTPRequestType>, HTTPResponseType>) async throws -> HTTPResponseType

    public var id: String

    public init<MiddlewareType: RequestMiddlewareProtocol>(_ realMiddleware: MiddlewareType)
    where MiddlewareType.HTTPRequestType == HTTPRequestType, MiddlewareType.HTTPResponseType == HTTPResponseType {
        if let alreadyErased = realMiddleware as? AnyRequestMiddleware<HTTPRequestType, HTTPResponseType> {
            self = alreadyErased
            return
        }

        self.id = realMiddleware.id
        self._handle = realMiddleware.handle
    }
    
    public init<HandlerType: HandlerProtocol>(handler: HandlerType, id: String)
    where HandlerType.Input == HttpRequestBuilder<HTTPRequestType>, HandlerType.Output == HTTPResponseType {
        
        self._handle = { input, handler in
            try await handler.handle(input: input)
        }
        self.id = id
    }

    public func handle<HandlerType: HandlerProtocol>(input: HttpRequestBuilder<HTTPRequestType>, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType.Input == HttpRequestBuilder<HTTPRequestType>,
          HandlerType.Output == HTTPResponseType {
        return try await _handle(input, next.eraseToAnyHandler())
    }
}
#else
public typealias AnyRequestMiddleware<MInput, MOutput> = any AnyRequestMiddleware<MInput, MOutput>
#endif
