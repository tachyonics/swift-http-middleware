// Copyright 2022 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//
//  AnyUnknownErrorHandler.swift
//  HttpServerRequestRouter
//

import HttpMiddleware

#if compiler(<5.7)
/// type erase the UnknownErrorHandlerProtocol protocol
public struct AnyUnknownErrorHandler<HTTPResponseType: HttpServerResponseProtocol, ContextType>: UnknownErrorHandlerProtocol {
    
    private let _handle: (Swift.Error, ContextType) -> HTTPResponseType

    public init<UnknownErrorHandlerType: UnknownErrorHandlerProtocol>(_ realUnknownErrorHandler: UnknownErrorHandlerType)
    where UnknownErrorHandlerType.HTTPResponseType == HTTPResponseType, UnknownErrorHandlerType.ContextType == ContextType {
        if let alreadyErased = realUnknownErrorHandler as? AnyUnknownErrorHandler {
            self = alreadyErased
            return
        }

        self._handle = realUnknownErrorHandler.handle
    }

    public func handle(error: Swift.Error, context: ContextType) -> HTTPResponseType {
        return self._handle(error, context)
    }
}
#else
public typealias AnyUnknownErrorHandler<InputHTTPRequestType, OutputHTTPRequestType, HTTPResponseType>
    = any UnknownErrorHandlerProtocol<InputHTTPRequestType, OutputHTTPRequestType, HTTPResponseType>
#endif
