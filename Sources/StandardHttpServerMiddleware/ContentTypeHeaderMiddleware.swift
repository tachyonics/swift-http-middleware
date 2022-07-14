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
import HttpServerMiddleware

public struct ContentTypeHeaderMiddleware<HTTPRequestType: HttpServerRequestProtocol,
                                          HTTPResponseType: HttpServerResponseProtocol>: ContentTypeMiddlewareProtocol {
    public typealias InputType = HTTPRequestType
    public typealias OutputType = HttpServerResponseBuilder<HTTPResponseType>
    
    private let contentType: String
    private let omitHeaderForZeroLengthBody: Bool
    
    public init(contentType: String,
                omitHeaderForZeroLengthBody: Bool) {
        self.contentType = contentType
        self.omitHeaderForZeroLengthBody = omitHeaderForZeroLengthBody
    }
    
    public func handle<HandlerType>(input: HTTPRequestType,
                                    context: MiddlewareContext, next: HandlerType) async throws
    -> HttpServerResponseBuilder<HTTPResponseType>
    where HandlerType : MiddlewareHandlerProtocol, HTTPRequestType == HandlerType.InputType,
    HttpServerResponseBuilder<HTTPResponseType> == HandlerType.OutputType {
        let builder = try await next.handle(input: input, context: context)
        
        if builder.body?.knownLength != 0 || !self.omitHeaderForZeroLengthBody {
            builder.withHeader(name: "Content-Type", value: self.contentType)
        }
        
        return builder
    }
}
