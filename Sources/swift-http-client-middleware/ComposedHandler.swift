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
//  ComposedHandler.swift
//  swift-http-client-middleware
//

// handler chain, used to decorate a handler with middleware
public struct ComposedHandler<MInput, MOutput> {
    // the next handler to call
    let next: AnyHandler<MInput, MOutput>
    
    // the middleware decorating 'next'
    let with: AnyMiddleware<MInput, MOutput>
    
    public init<H: HandlerProtocol, M: MiddlewareProtocol> (_ realNext: H, _ realWith: M)
    where H.Input == MInput,
          H.Output == MOutput,
          M.MInput == MInput,
          M.MOutput == MOutput {
        
        self.next = realNext.eraseToAnyHandler()
        self.with = realWith.eraseToAnyMiddleware()
    }
}

extension ComposedHandler: HandlerProtocol {
    public func handle(input: MInput) async throws -> MOutput {
        return try await with.handle(input: input, next: next)
    }
}
