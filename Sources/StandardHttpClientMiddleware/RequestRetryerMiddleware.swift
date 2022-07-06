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

public enum RequestRetryerError: Error {
    case maximumRetryAttemptsExceeded(attemptCount: Int, mostRecentError: Swift.Error?)
}

public struct RequestRetryerMiddleware<HTTPRequestType: HttpRequestProtocol,
                                       HTTPResponseType: HttpResponseProtocol>: RequestRetryerMiddlewareProtocol {
    public typealias InputType = HTTPRequestType
    public typealias OutputType = HTTPResponseType
    
    private let retryConfiguration: HTTPClientRetryConfiguration
    private let canRetryErrorFunction: (Swift.Error) -> Bool
    
    public init(retryConfiguration: HTTPClientRetryConfiguration,
                canRetryErrorFunction: @escaping (Swift.Error) -> Bool) {
        self.retryConfiguration = retryConfiguration
        self.canRetryErrorFunction = canRetryErrorFunction
    }
    
    public func handle<HandlerType>(input: HTTPRequestType, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : HandlerProtocol, HTTPRequestType == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {
        return try await handle(input: input, next: next,
                                retriesRemaining: self.retryConfiguration.numRetries,
                                mostRecentError: nil)
    }
    
    private func handle<HandlerType>(input: HTTPRequestType, next: HandlerType,
                                     retriesRemaining: Int, mostRecentError: Swift.Error?) async throws
    -> HTTPResponseType
    where HandlerType : HandlerProtocol, HTTPRequestType == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {
        guard retriesRemaining > 0 else {
            throw RequestRetryerError.maximumRetryAttemptsExceeded(attemptCount: self.retryConfiguration.numRetries,
                                                                   mostRecentError: mostRecentError)
        }
        
        do {
            return try await next.handle(input: input)
        } catch let error where self.canRetryErrorFunction(error) {
            return try await handle(input: input, next: next, retriesRemaining: retriesRemaining - 1, mostRecentError: error)
        }
    }
}
