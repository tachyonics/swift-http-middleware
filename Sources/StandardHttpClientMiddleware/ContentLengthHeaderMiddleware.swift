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

public struct ContentLengthHeaderMiddleware<HTTPRequestType: HttpRequestProtocol,
                                            HTTPResponseType: HttpResponseProtocol>: ContentLengthMiddlewareProtocol {
    public typealias InputType = HttpRequestBuilder<HTTPRequestType>
    public typealias OutputType = HTTPResponseType
    
    private let omitHeaderForZeroOrUnknownSizedBody: Bool
    
    public init(omitHeaderForZeroOrUnknownSizedBody: Bool) {
        self.omitHeaderForZeroOrUnknownSizedBody = omitHeaderForZeroOrUnknownSizedBody
    }
    
    public func handle<HandlerType>(input: HttpRequestBuilder<HTTPRequestType>, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : HandlerProtocol, HttpRequestBuilder<HTTPRequestType> == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {
        let effectiveBodySize = input.knownBodySize ?? 0
        
        if effectiveBodySize != 0 || !self.omitHeaderForZeroOrUnknownSizedBody {
            input.withHeader(name: "Content-Length", value: "\(effectiveBodySize)")
        }
        
        return try await next.handle(input: input)
    }
}
