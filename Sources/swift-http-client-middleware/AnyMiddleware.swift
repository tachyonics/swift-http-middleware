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
//  swift-http-client-middleware
//

#if compiler(<5.7)
/// type erase the Middleware protocol
public struct AnyMiddleware<MInput, MOutput>: MiddlewareProtocol {
    
    private let _handle: (MInput, AnyHandler<MInput, MOutput>) async throws -> MOutput

    public var id: String

    public init<M: MiddlewareProtocol>(_ realMiddleware: M)
    where M.MInput == MInput, M.MOutput == MOutput {
        if let alreadyErased = realMiddleware as? AnyMiddleware<MInput, MOutput> {
            self = alreadyErased
            return
        }

        self.id = realMiddleware.id
        self._handle = realMiddleware.handle
    }
    
    public init<H: HandlerProtocol>(handler: H, id: String) where H.Input == MInput,
                                                                  H.Output == MOutput {
        
        self._handle = { input, handler in
            try await handler.handle(input: input)
        }
        self.id = id
    }

    public func handle<H: HandlerProtocol>(input: MInput, next: H) async throws -> MOutput
    where H.Input == MInput,
          H.Output == MOutput {
        return try await _handle(input, next.eraseToAnyHandler())
    }
}
#else
public typealias AnyMiddleware<MInput, MOutput> = any MiddlewareProtocol<MInput, MOutput>
#endif
