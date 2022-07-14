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
//  AnyMiddleware.swift
//  HttpMiddleware
//

#if compiler(<5.7)
/// type erase the Middleware protocol
public struct AnyMiddleware<InputType, OutputType>: MiddlewareProtocol {
    
    private let _handle: (InputType, MiddlewareContext,
                          AnyMiddlewareHandler<InputType, OutputType>) async throws -> OutputType

    public var id: String

    public init<MiddlewareType: MiddlewareProtocol>(_ realMiddleware: MiddlewareType)
    where MiddlewareType.InputType == InputType, MiddlewareType.OutputType == OutputType {
        if let alreadyErased = realMiddleware as? AnyMiddleware {
            self = alreadyErased
            return
        }

        self.id = realMiddleware.id
        self._handle = realMiddleware.handle
    }

    public init<HandlerType: HandlerProtocol>(handler: HandlerType, id: String)
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        
        self._handle = { input, context, handler in
            try await handler.handle(input: input, context: context)
        }
        self.id = id
    }

    public func handle<HandlerType: MiddlewareHandlerProtocol>(input: InputType, context: MiddlewareContext, next: HandlerType) async throws
    -> OutputType
    where HandlerType.InputType == InputType,
          HandlerType.OutputType == OutputType {
        return try await _handle(input, context, next.eraseToAnyHandler())
    }
}
#else
public typealias AnyMiddleware<MInput, MOutput> = any MiddlewareProtocol<MInput, MOutput>
#endif
