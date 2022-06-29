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
//  TypedInputOutputPhase.swift
//  swift-http-client-middleware
//
/*
public protocol TypedInputOutputPhaseMiddlewareProtocol: MiddlewareProtocol {
    
    func handle<HandlerType: HandlerProtocol, InputType, HTTPResponseType, OutputType>(
        input: InputType,
        next: HandlerType) async throws -> OperationOutput<OutputType, HTTPResponseType>
    where HandlerType.Input == InputType, HandlerType.Output == OperationOutput<OutputType, HTTPResponseType>
}

public struct TypedInputOutputPhase {
    var orderedMiddleware: OrderedGroup = OrderedGroup()
    
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
    
    mutating func intercept<M: MiddlewareProtocol>(position: AbsolutePosition, middleware: M) {
        orderedMiddleware.add(middleware: middleware, position: position)
    }
    
    /// Convenience function for passing a closure directly:
    ///
    /// ```
    /// stack.intercept(position: .after, id: "Add Header") { ... }
    /// ```
    ///
    mutating func intercept<Input, Output>(position: AbsolutePosition,
                                   id: String,
                                   middleware: @escaping MiddlewareFunction<Input, Output>) {
        let middleware = WrappedMiddleware(middleware, id: id)
        orderedMiddleware.add(middleware: middleware, position: position)
    }
    
    /// Compose (wrap) the handler with the given middleware or essentially build out the linked list of middleware
    internal func compose<HandlerType: HandlerProtocol, OutputType, HTTPResponseType>(
        next: HandlerType) -> AnyHandler<HandlerType.Input, HandlerType.Output>
    where HandlerType.Output == OperationOutput<OutputType, HTTPResponseType> {
        var handler = next.eraseToAnyHandler()
        let order = orderedMiddleware.orderedItems
        
        guard !order.isEmpty else {
            return handler
        }
        let numberOfMiddlewares = order.count
        let reversedCollection = (0...(numberOfMiddlewares-1)).reversed()
        for index in reversedCollection {
            let currentMiddleware = order[index].value as! TypedInputOutputPhaseMiddlewareProtocol
            let composedHandler = ComposedTypedInputOutputPhaseHandler(handler, currentMiddleware)
            handler = composedHandler.eraseToAnyHandler()
        }
        
        return handler.eraseToAnyHandler()
    }
}

// handler chain, used to decorate a handler with middleware
struct ComposedTypedInputOutputPhaseHandler<InputType, HTTPResponseType, OutputType> {
    // the next handler to call
    let next: AnyHandler<InputType, OperationOutput<OutputType, HTTPResponseType>>
    
    // the middleware decorating 'next'
    let with: TypedInputOutputPhaseMiddlewareProtocol
    
    public init<HandlerType: HandlerProtocol> (_ realNext: HandlerType, _ realWith: TypedInputOutputPhaseMiddlewareProtocol)
    where HandlerType.Input == InputType, HandlerType.Output == OperationOutput<OutputType, HTTPResponseType>
    {
        
        self.next = realNext.eraseToAnyHandler()
        self.with = realWith
    }
}

extension ComposedTypedInputOutputPhaseHandler: HandlerProtocol {
    public func handle(input: InputType) async throws -> OperationOutput<OutputType, HTTPResponseType> {
        return try await with.handle(input: input, next: next)
    }
}
*/
