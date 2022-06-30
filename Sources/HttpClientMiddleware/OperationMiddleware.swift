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
//  OperationMiddleware.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
public protocol OperationMiddlewareProtocol: MiddlewareProtocol {
    associatedtype InputType
    associatedtype OutputType
    
    func handle<HandlerType: HandlerProtocol>(
        input: InputType,
        next: HandlerType) async throws -> OutputType
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType
}

extension OperationMiddlewareProtocol {
    public func eraseToAnyOperationMiddleware() -> AnyOperationMiddleware<InputType, OutputType> {
        return AnyOperationMiddleware(self)
    }
}
#else
public protocol OperationMiddlewareProtocol<InputType, OutputType>: MiddlewareProtocol {
    associatedtype InputType
    associatedtype OutputType
    
    func handle<HandlerType: HandlerProtocol>(
        input: InputType,
        next: HandlerType) async throws -> OutputType
    where HandlerType.Input == InputType, HandlerType.Output == OutputType
}

extension OperationMiddlewareProtocol {
    public func eraseToAnyOperationMiddleware() -> any OperationMiddlewareProtocol {
        return self
    }
}
#endif

public struct OperationMiddlewarePhase<InputType, OutputType> {
    var orderedMiddleware: OrderedGroup<AnyOperationMiddleware<InputType, OutputType>> = OrderedGroup()
    
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
    
    mutating func intercept<MiddlewareType: OperationMiddlewareProtocol>(position: AbsolutePosition, middleware: MiddlewareType)
    where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType {
        orderedMiddleware.add(middleware: middleware.eraseToAnyOperationMiddleware(), position: position)
    }
    
    /// Convenience function for passing a closure directly:
    ///
    /// ```
    /// stack.intercept(position: .after, id: "Add Header") { ... }
    /// ```
    ///
    mutating func intercept(position: AbsolutePosition,
                                   id: String,
                                   middleware: @escaping OperationMiddlewareFunction<InputType, OutputType>) {
        let middleware = WrappedOperationMiddleware(middleware, id: id)
        orderedMiddleware.add(middleware: middleware.eraseToAnyOperationMiddleware(), position: position)
    }
    
    /// Compose (wrap) the handler with the given middleware or essentially build out the linked list of middleware
    internal func compose<HandlerType: HandlerProtocol>(
        next: HandlerType) -> AnyHandler<HandlerType.InputType, HandlerType.OutputType>
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        var handler = next.eraseToAnyHandler()
        let order = orderedMiddleware.orderedItems
        
        guard !order.isEmpty else {
            return handler
        }
        let numberOfMiddlewares = order.count
        let reversedCollection = (0...(numberOfMiddlewares-1)).reversed()
        for index in reversedCollection {
            let composedHandler = ComposedOperationMiddlewarePhaseHandler(handler, order[index].value)
            handler = composedHandler.eraseToAnyHandler()
        }
        
        return handler.eraseToAnyHandler()
    }
}

// handler chain, used to decorate a handler with middleware
struct ComposedOperationMiddlewarePhaseHandler<InputType, OutputType> {
    // the next handler to call
    let next: AnyHandler<InputType, OutputType>
    
    // the middleware decorating 'next'
    let with: AnyOperationMiddleware<InputType, OutputType>
    
    public init<HandlerType: HandlerProtocol, MiddlewareType: OperationMiddlewareProtocol>(
        _ realNext: HandlerType, _ realWith: MiddlewareType)
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType,
          MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType
    {
        
        self.next = realNext.eraseToAnyHandler()
        self.with = realWith.eraseToAnyOperationMiddleware()
    }
}

extension ComposedOperationMiddlewarePhaseHandler: HandlerProtocol {
    public func handle(input: InputType) async throws -> OutputType {
        return try await with.handle(input: input, next: next)
    }
}
