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

public struct ContentTypeHeaderMiddleware<HTTPRequestType: HttpClientRequestProtocol,
                                          HTTPResponseType: HttpClientResponseProtocol>: ContentTypeMiddlewareProtocol {
    public typealias InputType = HttpClientRequestBuilder<HTTPRequestType>
    public typealias OutputType = HTTPResponseType
    
    private let contentType: String
    private let omitHeaderForZeroLengthBody: Bool
    
    public init(contentType: String,
                omitHeaderForZeroLengthBody: Bool) {
        self.contentType = contentType
        self.omitHeaderForZeroLengthBody = omitHeaderForZeroLengthBody
    }
    
    public func handle<HandlerType>(input: HttpClientRequestBuilder<HTTPRequestType>,
                                    context: MiddlewareContext, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : MiddlewareHandlerProtocol, HttpClientRequestBuilder<HTTPRequestType> == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {
        if input.body?.knownLength != 0 || !self.omitHeaderForZeroLengthBody {
            input.withHeader(name: "Content-Type", value: self.contentType)
        }
        
        return try await next.handle(input: input, context: context)
    }
}
