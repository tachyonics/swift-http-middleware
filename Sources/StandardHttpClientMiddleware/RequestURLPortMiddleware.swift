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

public struct RequestURLPortMiddleware<HTTPRequestType: HttpRequestProtocol,
                                               HTTPResponseType: HttpResponseProtocol>: RequestURLPortMiddlewareProtocol {
    public typealias InputType = HttpRequestBuilder<HTTPRequestType>
    public typealias OutputType = HTTPResponseType
    
    private let urlPort: Int16
    
    public init(urlPort: Int16) {
        self.urlPort = urlPort
    }
    
    public func handle<HandlerType>(input: HttpRequestBuilder<HTTPRequestType>, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : HandlerProtocol, HttpRequestBuilder<HTTPRequestType> == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {

        input.withPort(self.urlPort)
        
        return try await next.handle(input: input)
    }
}
