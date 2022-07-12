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

public struct RequestURLHostMiddleware<HTTPRequestType: HttpClientRequestProtocol,
                             HTTPResponseType: HttpClientResponseProtocol>: RequestURLHostMiddlewareProtocol {
    public typealias InputType = HttpClientRequestBuilder<HTTPRequestType>
    public typealias OutputType = HTTPResponseType
    
    private let urlHost: String
    private let addHeader: Bool
    
    public init(urlHost: String, addHeader: Bool) {
        self.urlHost = urlHost
        self.addHeader = addHeader
    }
    
    public func handle<HandlerType>(input: HttpClientRequestBuilder<HTTPRequestType>, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : HandlerProtocol, HttpClientRequestBuilder<HTTPRequestType> == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {
        if addHeader {
            input.withHeader(name: "Host", value: self.urlHost)
        }
        
        input.withHost(self.urlHost)
        
        return try await next.handle(input: input)
    }
}
