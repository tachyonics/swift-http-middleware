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

public enum RequestRetryerResult<HTTPResponseType: HttpClientResponseProtocol>: _MiddlewareSendable {
    case response(HTTPResponseType)
    case error(cause: Swift.Error, code: UInt)
}

public enum RequestRetryerError<HTTPResponseType: HttpClientResponseProtocol>: Error {
    case maximumRetryAttemptsExceeded(attemptCount: Int, mostRecentResult: RequestRetryerResult<HTTPResponseType>)
}

public struct RequestRetryerMiddleware<HTTPRequestType: HttpClientRequestProtocol,
                                       HTTPResponseType: HttpClientResponseProtocol>: RequestRetryerMiddlewareProtocol {
    public typealias InputType = HTTPRequestType
    public typealias OutputType = HTTPResponseType
    
    private let retryConfiguration: HTTPClientRetryConfiguration
    private let errorStatusFunction: (Swift.Error) -> (isRetriable: Bool, code: UInt)
    
    public init(retryConfiguration: HTTPClientRetryConfiguration,
                errorStatusFunction: @escaping (Swift.Error) -> (isRetriable: Bool, code: UInt)) {
        self.retryConfiguration = retryConfiguration
        self.errorStatusFunction = errorStatusFunction
    }
    
    public func handle<HandlerType>(input: HTTPRequestType,
                                    context: MiddlewareContext, next: HandlerType) async throws
    -> HTTPResponseType
    where HandlerType : MiddlewareHandlerProtocol, HTTPRequestType == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {
        return try await handle(input: input, context: context, next: next,
                                retriesRemaining: self.retryConfiguration.numRetries,
                                mostRecentResult: nil)
    }
    
    private func handle<HandlerType>(input: HTTPRequestType, context: MiddlewareContext, next: HandlerType,
                                     retriesRemaining: Int,
                                     mostRecentResult: RequestRetryerResult<HTTPResponseType>?) async throws
    -> HTTPResponseType
    where HandlerType : MiddlewareHandlerProtocol, HTTPRequestType == HandlerType.InputType,
    HTTPResponseType == HandlerType.OutputType {
        if let mostRecentResult = mostRecentResult {
            guard retriesRemaining > 0 else {
                throw RequestRetryerError.maximumRetryAttemptsExceeded(attemptCount: self.retryConfiguration.numRetries,
                                                                       mostRecentResult: mostRecentResult)
            }
        }
        
        do {
            let response = try await next.handle(input: input, context: context)
            
            switch response.statusCode {
            case 500...599:
                try await self.retryConfiguration.waitForNextRetry(retriesRemaining: retriesRemaining)
                
                // server error, retry
                return try await handle(input: input, context: context, next: next, retriesRemaining: retriesRemaining - 1,
                                        mostRecentResult: .response(response))
            default:
                return response
            }
        } catch {
            let status = self.errorStatusFunction(error)
            let result: RequestRetryerResult<HTTPResponseType> = .error(cause: error, code: status.code)
            
            if status.isRetriable {
                try await self.retryConfiguration.waitForNextRetry(retriesRemaining: retriesRemaining)
                
                return try await handle(input: input, context: context, next: next, retriesRemaining: retriesRemaining - 1, mostRecentResult: result)
            }
            
            // rethrow error
            throw error
        }
    }
}
