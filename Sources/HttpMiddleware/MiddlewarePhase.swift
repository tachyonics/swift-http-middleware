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
//  MiddlewarePhase.swift
//  HttpMiddleware
//

public struct MiddlewarePhase<InputType, OutputType>: Sendable {
    var orderedMiddleware: OrderedGroup<AnyMiddleware<InputType, OutputType>> = OrderedGroup()
    
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
    
    public mutating func intercept<MiddlewareType: MiddlewareProtocol>(at position: AbsolutePosition = .end, with middleware: MiddlewareType)
    where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType {
        orderedMiddleware.add(middleware: middleware.eraseToAnyMiddleware(), position: position)
    }
    
    /// Convenience function for passing a closure directly:
    ///
    /// ```
    /// stack.intercept(position: .after, id: "Add Header") { ... }
    /// ```
    ///
    public mutating func intercept(at position: AbsolutePosition = .end,
                                   id: String,
                                   with middleware: @escaping MiddlewareFunction<InputType, OutputType>) {
        let middleware = WrappedMiddleware(middleware, id: id)
        orderedMiddleware.add(middleware: middleware.eraseToAnyMiddleware(), position: position)
    }
    
    /// Compose (wrap) the handler with the given middleware or essentially build out the linked list of middleware
    public func compose<HandlerType: MiddlewareHandlerProtocol>(
        next: HandlerType) -> AnyMiddlewareHandler<HandlerType.InputType, HandlerType.OutputType>
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        var handler = next.eraseToAnyHandler()
        let order = orderedMiddleware.orderedItems
        
        guard !order.isEmpty else {
            return handler
        }
        let numberOfMiddlewares = order.count
        let reversedCollection = (0...(numberOfMiddlewares-1)).reversed()
        for index in reversedCollection {
            let composedHandler = ComposedMiddlewarePhaseHandler(handler, order[index].value)
            handler = composedHandler.eraseToAnyHandler()
        }
        
        return handler.eraseToAnyHandler()
    }
}

// handler chain, used to decorate a handler with middleware
struct ComposedMiddlewarePhaseHandler<InputType, OutputType> {
    // the next handler to call
    let next: AnyHandler<InputType, OutputType, MiddlewareContext>
    
    // the middleware decorating 'next'
    let with: AnyMiddleware<InputType, OutputType>
    
    public init<HandlerType: MiddlewareHandlerProtocol, MiddlewareType: MiddlewareProtocol>(
        _ realNext: HandlerType, _ realWith: MiddlewareType)
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType,
          MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType
    {
        
        self.next = realNext.eraseToAnyHandler()
        self.with = realWith.eraseToAnyMiddleware()
    }
}

extension ComposedMiddlewarePhaseHandler: HandlerProtocol {
    public func handle(input: InputType, context: MiddlewareContext) async throws -> OutputType {
        return try await with.handle(input: input, context: context, next: next)
    }
}
