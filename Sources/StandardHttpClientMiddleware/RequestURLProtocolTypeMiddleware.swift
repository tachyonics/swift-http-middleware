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

import HttpClientMiddleware

public struct RequestURLProtocolTypeMiddleware<HTTPRequestType: HttpRequestProtocol,
                                               HTTPResponseType: HttpResponseProtocol>: RequestURLProtocolTypeMiddlewareProtocol {
    public typealias InputType = HttpRequestBuilder<HTTPRequestType>
    public typealias OutputType = HTTPResponseType
    
    private let urlProtocolType: ProtocolType
    
    public init(urlProtocolType: ProtocolType) {
        self.urlProtocolType = urlProtocolType
    }
    
    public func handle<HandlerType>(input: HttpRequestBuilder<HTTPRequestType>, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : HandlerProtocol, HttpRequestBuilder<HTTPRequestType> == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {

        input.withProtocol(self.urlProtocolType)
        
        return try await next.handle(input: input)
    }
}
