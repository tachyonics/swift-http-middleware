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
//  InitializePhase.swift
//  swift-http-client-middleware
//

/// Initialize Prepares the input, and sets any default parameters as
/// needed, (e.g. idempotency token, and presigned URLs).
///
/// Takes Input Parameters, and returns result or error.
///
/// Receives result or error from the serialization transform.
public typealias InitializePhase<I, O, HTTPResponseType> = MiddlewarePhase<I, OperationOutput<O, HTTPResponseType>>

public let InitializePhaseId = "Initialize"

public struct InitializePhaseHandler<OperationStackInput,
                                    OperationStackOutput,
                                    HTTPResponseType,
                                    H: HandlerProtocol>: HandlerProtocol
where H.Input == OperationStackInput, H.Output == OperationOutput<OperationStackOutput, HTTPResponseType> {
    
    public typealias Input = OperationStackInput
    
    public typealias Output = OperationOutput<OperationStackOutput, HTTPResponseType>
    
    let handler: H
    
    public init(handler: H) {
        self.handler = handler
    }
    
    public func handle(input: Input) async throws -> Output {
        return try await handler.handle(input: input)
    }
}
