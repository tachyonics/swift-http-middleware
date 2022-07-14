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

import HttpMiddleware
import HttpClientMiddleware

public struct RequestURLProtocolTypeMiddleware<HTTPRequestType: HttpClientRequestProtocol,
                                               HTTPResponseType: HttpClientResponseProtocol>: RequestURLProtocolTypeMiddlewareProtocol {
    public typealias InputType = HttpClientRequestBuilder<HTTPRequestType>
    public typealias OutputType = HTTPResponseType
    
    private let urlProtocolType: ProtocolType
    
    public init(urlProtocolType: ProtocolType) {
        self.urlProtocolType = urlProtocolType
    }
    
    public func handle<HandlerType>(input: HttpClientRequestBuilder<HTTPRequestType>,
                                    context: MiddlewareContext, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : MiddlewareHandlerProtocol, HttpClientRequestBuilder<HTTPRequestType> == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {

        input.withProtocol(self.urlProtocolType)
        
        return try await next.handle(input: input, context: context)
    }
}
