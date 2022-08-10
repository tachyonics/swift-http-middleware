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
//  WrappedMiddleware.swift
//  HttpMiddleware
//

/// used to create middleware from a middleware function
/*struct WrappedMiddleware<InputType, OutputType>: MiddlewareProtocol {
    let _middleware: MiddlewareFunction<InputType, OutputType>
    var id: String
    
    init(_ middleware: @escaping MiddlewareFunction<InputType, OutputType>, id: String) {
        self._middleware = middleware
        self.id = id
    }
    
    func handle<HandlerType: MiddlewareHandlerProtocol>(
        input: InputType,
        context: MiddlewareContext,
        next: HandlerType) async throws -> OutputType
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        return try await _middleware(input, context, next.eraseToAnyHandler())
    }
}*/
