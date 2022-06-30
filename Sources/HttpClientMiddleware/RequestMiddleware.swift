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
//  RequestMiddleware.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
public protocol RequestMiddlewareProtocol: MiddlewareProtocol {
    associatedtype HTTPRequestType: HttpRequestProtocol
    associatedtype HTTPResponseType: HttpResponseProtocol
    
    func handle<HandlerType: HandlerProtocol>(
        input: HttpRequestBuilder<HTTPRequestType>,
        next: HandlerType) async throws -> HTTPResponseType
    where HandlerType.InputType == HttpRequestBuilder<HTTPRequestType>, HandlerType.OutputType == HTTPResponseType
}

extension RequestMiddlewareProtocol {
    public func eraseToAnyRequestMiddleware() -> AnyRequestMiddleware<HTTPRequestType, HTTPResponseType> {
        return AnyRequestMiddleware(self)
    }
}
#else
public protocol RequestMiddlewareProtocol<HTTPRequestType, HTTPResponseType>: MiddlewareProtocol {
    associatedtype HTTPRequestType: HttpRequestProtocol
    associatedtype HTTPResponseType: HttpResponseProtocol
    
    func handle<HandlerType: HandlerProtocol>(
        input: HttpRequestBuilder<HTTPRequestType>,
        next: HandlerType) async throws -> HTTPResponseType
    where HandlerType.Input == HttpRequestBuilder<HTTPRequestType>, HandlerType.Output == HTTPResponseType
}

extension RequestMiddlewareProtocol {
    public func eraseToAnyRequestMiddleware() -> any RequestMiddlewareProtocol<HTTPRequestType, HTTPResponseType> {
        return self
    }
}
#endif

public struct RequestMiddlewarePhase<HTTPRequestType: HttpRequestProtocol, HTTPResponseType: HttpResponseProtocol> {
    var orderedMiddleware: OrderedGroup<AnyRequestMiddleware<HTTPRequestType, HTTPResponseType>> = OrderedGroup()
    
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
    
    mutating func intercept<MiddlewareType: RequestMiddlewareProtocol>(position: AbsolutePosition, middleware: MiddlewareType)
    where MiddlewareType.HTTPRequestType == HTTPRequestType, MiddlewareType.HTTPResponseType == HTTPResponseType {
        orderedMiddleware.add(middleware: middleware.eraseToAnyRequestMiddleware(), position: position)
    }
    
    /// Convenience function for passing a closure directly:
    ///
    /// ```
    /// stack.intercept(position: .after, id: "Add Header") { ... }
    /// ```
    ///
    mutating func intercept(position: AbsolutePosition,
                                   id: String,
                                   middleware: @escaping RequestMiddlewareFunction<HTTPRequestType, HTTPResponseType>) {
        let middleware = WrappedRequestMiddleware(middleware, id: id)
        orderedMiddleware.add(middleware: middleware.eraseToAnyRequestMiddleware(), position: position)
    }
    
    /// Compose (wrap) the handler with the given middleware or essentially build out the linked list of middleware
    internal func compose<HandlerType: HandlerProtocol>(
        next: HandlerType) -> AnyHandler<HandlerType.InputType, HandlerType.OutputType>
    where HandlerType.InputType == HttpRequestBuilder<HTTPRequestType>, HandlerType.OutputType == HTTPResponseType {
        var handler = next.eraseToAnyHandler()
        let order = orderedMiddleware.orderedItems
        
        guard !order.isEmpty else {
            return handler
        }
        let numberOfMiddlewares = order.count
        let reversedCollection = (0...(numberOfMiddlewares-1)).reversed()
        for index in reversedCollection {
            let composedHandler = ComposedRequestMiddlewarePhaseHandler(handler, order[index].value)
            handler = composedHandler.eraseToAnyHandler()
        }
        
        return handler.eraseToAnyHandler()
    }
}

// handler chain, used to decorate a handler with middleware
struct ComposedRequestMiddlewarePhaseHandler<HTTPRequestType: HttpRequestProtocol, HTTPResponseType: HttpResponseProtocol> {
    // the next handler to call
    let next: AnyHandler<HttpRequestBuilder<HTTPRequestType>, HTTPResponseType>
    
    // the middleware decorating 'next'
    let with: AnyRequestMiddleware<HTTPRequestType, HTTPResponseType>
    
    public init<HandlerType: HandlerProtocol, MiddlewareType: RequestMiddlewareProtocol>(
        _ realNext: HandlerType, _ realWith: MiddlewareType)
    where HandlerType.InputType == HttpRequestBuilder<HTTPRequestType>, HandlerType.OutputType == HTTPResponseType,
          MiddlewareType.HTTPRequestType == HTTPRequestType, MiddlewareType.HTTPResponseType == HTTPResponseType
    {
        
        self.next = realNext.eraseToAnyHandler()
        self.with = realWith.eraseToAnyRequestMiddleware()
    }
}

extension ComposedRequestMiddlewarePhaseHandler: HandlerProtocol {
    public func handle(input: HttpRequestBuilder<HTTPRequestType>) async throws -> HTTPResponseType {
        return try await with.handle(input: input, next: next)
    }
}
