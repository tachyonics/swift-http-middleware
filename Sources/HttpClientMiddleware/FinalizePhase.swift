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
//  FinalizePhase.swift
//  swift-http-client-middleware
//

// Performs final preparations needed before sending the message. The
// message should already be complete by this stage, and is only alternated
// to meet the expectations of the recipient, (e.g. Retry and authentication
// request signing)
//
// Takes Request, and returns result or error.
//
// Receives result or error from Deserialize phase (if present).
public typealias FinalizePhase<HttpRequestType: HttpRequestProtocol, PhaseOutput> =
    MiddlewarePhase<HttpRequestBuilder<HttpRequestType>, PhaseOutput>

public let FinalizePhaseId = "Finalize"

public struct FinalizePhaseHandler<StackOutput, HttpRequestType: HttpRequestProtocol, HandlerType: HandlerProtocol>: HandlerProtocol
where HandlerType.Input == HttpRequestBuilder<HttpRequestType>, HandlerType.Output == StackOutput {

    public typealias Input = HttpRequestBuilder<HttpRequestType>
    
    public typealias Output = StackOutput
    
    let handler: HandlerType
    
    public init(handler: HandlerType) {
        self.handler = handler
    }
    
    public func handle(input: Input) async throws -> Output {
        return try await handler.handle(input: input)
    }
}
