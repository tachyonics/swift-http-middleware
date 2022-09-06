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
//  ServerOperationHandler.swift
//  HttpServerMiddleware
//

import SwiftMiddleware

public struct ServerOperationHandler<PhaseType: MiddlewarePhaseProtocol, HTTPRequestType: HttpServerRequestProtocol,
                                     HTTPResponseType: HttpServerResponseProtocol>: MiddlewareHandlerProtocol
where PhaseType.InputType == HTTPRequestType, PhaseType.OutputType: HttpServerResponseBuilderProtocol,
PhaseType.OutputType.HTTPResponseType == HTTPResponseType {
    private let phase: PhaseType
    
    public init(phase: PhaseType) {
        self.phase = phase
    }
    
    public func handle(input: HTTPRequestType, context: MiddlewareContext) async throws -> PhaseType.OutputType {
        let phaseHandler = ComposedMiddlewarePhaseHandler(next: phase.next, with: phase.with)
        
        return try await phaseHandler.handle(input: input, context: context)
    }
}

