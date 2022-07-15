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
//  UnknownErrorHandlerProtocol.swift
//  HttpServerMiddleware
//

#if compiler(<5.7)
public protocol UnknownErrorHandlerProtocol {
    associatedtype HTTPResponseType: HttpServerResponseProtocol
    associatedtype ContextType
    
    func handle(error: Swift.Error, context: ContextType) -> HTTPResponseType
}

extension UnknownErrorHandlerProtocol {
    public func eraseToAnyUnknownErrorHandler() -> AnyUnknownErrorHandler<HTTPResponseType, ContextType> {
        return AnyUnknownErrorHandler(self)
    }
}
#else
public protocol UnknownErrorHandlerProtocol<HTTPResponseType, ContextType> {
    associatedtype HTTPResponseType: HttpServerResponseProtocol
    
    func handle(error: Swift.Error) -> HTTPResponseType
}

extension UnknownErrorHandlerProtocol {
    public func eraseToAnyUnknownErrorHandler() -> any AnyUnknownErrorHandler<HTTPResponseType, ContextType> {
        return self
    }
}
#endif
