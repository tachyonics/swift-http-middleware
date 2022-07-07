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

public enum RequestRetryerErrorCause<HTTPResponseType: HttpResponseProtocol> {
    case response(HTTPResponseType)
    case error(Swift.Error)
}

public enum RequestRetryerError<HTTPResponseType: HttpResponseProtocol>: Error {
    case maximumRetryAttemptsExceeded(attemptCount: Int, cause: RequestRetryerErrorCause<HTTPResponseType>)
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
                                mostRecentFailure: nil)
    }
    
    private func handle<HandlerType>(input: HTTPRequestType, next: HandlerType,
                                     retriesRemaining: Int,
                                     mostRecentFailure: RequestRetryerErrorCause<HTTPResponseType>?) async throws
    -> HTTPResponseType
    where HandlerType : HandlerProtocol, HTTPRequestType == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {
        if let mostRecentFailure = mostRecentFailure {
            guard retriesRemaining > 0 else {
                throw RequestRetryerError.maximumRetryAttemptsExceeded(attemptCount: self.retryConfiguration.numRetries,
                                                                       cause: mostRecentFailure)
            }
        }
        
        do {
            let response = try await next.handle(input: input)
            
            switch response.statusCode {
            case 500...599:
                // server error, retry
                return try await handle(input: input, next: next, retriesRemaining: retriesRemaining - 1,
                                        mostRecentFailure: .response(response))
            default:
                return response
            }
        } catch let error where self.canRetryErrorFunction(error) {
            return try await handle(input: input, next: next, retriesRemaining: retriesRemaining - 1, mostRecentFailure: .error(error))
        }
    }
}
