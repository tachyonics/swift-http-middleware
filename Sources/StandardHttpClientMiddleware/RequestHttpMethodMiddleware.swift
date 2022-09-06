//===----------------------------------------------------------------------===//
//
// This source file is part of the async-http-middleware-client open source project
//
// Copyright (c) 2022 the async-http-middleware-client project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of VSCode Swift project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import SwiftMiddleware
import HttpMiddleware
import HttpClientMiddleware

public struct RequestHttpMethodMiddleware<HTTPRequestType: HttpClientRequestProtocol,
                                               HTTPResponseType: HttpClientResponseProtocol>: MiddlewareProtocol {
    public typealias InputType = HttpClientRequestBuilder<HTTPRequestType>
    public typealias OutputType = HTTPResponseType
    
    private let httpMethod: HttpMethod
    
    public init(httpMethod: HttpMethod) {
        self.httpMethod = httpMethod
    }
    
    public func handle<HandlerType>(input: HttpClientRequestBuilder<HTTPRequestType>,
                                    context: MiddlewareContext, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : MiddlewareHandlerProtocol, HttpClientRequestBuilder<HTTPRequestType> == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {

        input.withMethod(self.httpMethod)
        
        return try await next.handle(input: input, context: context)
    }
}
