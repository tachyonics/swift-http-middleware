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
//  WrappedRequestMiddleware.swift
//  swift-http-client-middleware
//

/// used to create middleware from a middleware function
struct WrappedRequestMiddleware<HTTPRequestType: HttpRequestProtocol, HTTPResponseType: HttpResponseProtocol>: RequestMiddlewareProtocol {
    let _middleware: RequestMiddlewareFunction<HTTPRequestType, HTTPResponseType>
    var id: String
    
    init(_ middleware: @escaping RequestMiddlewareFunction<HTTPRequestType, HTTPResponseType>, id: String) {
        self._middleware = middleware
        self.id = id
    }
    
    func handle<HandlerType: HandlerProtocol>(
        input: HttpRequestBuilder<HTTPRequestType>,
        next: HandlerType) async throws -> HTTPResponseType
    where HandlerType.Input == HttpRequestBuilder<HTTPRequestType>, HandlerType.Output == HTTPResponseType {
        return try await _middleware(input, next.eraseToAnyHandler())
    }
}
