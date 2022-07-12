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

public struct UserAgentHeaderMiddleware<HTTPRequestType: HttpClientRequestProtocol,
                                        HTTPResponseType: HttpClientResponseProtocol>: UserAgentHeaderMiddlewareProtocol {
    public typealias InputType = HttpClientRequestBuilder<HTTPRequestType>
    public typealias OutputType = HTTPResponseType
    
    private let userAgent: String
    
    public init(userAgent: String) {
        self.userAgent = userAgent
    }
    
    public func handle<HandlerType>(input: HttpClientRequestBuilder<HTTPRequestType>, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : HandlerProtocol, HttpClientRequestBuilder<HTTPRequestType> == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {
        input.withHeader(name: "User-Agent", value: self.userAgent)
        
        return try await next.handle(input: input)
    }
}
