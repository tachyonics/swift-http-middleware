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
//  AnyServerOperationHandler.swift
//  HttpServerMiddleware
//

import HttpMiddleware

public struct AnyServerOperationHandler<HTTPRequestType: HttpServerRequestProtocol,
                                        HTTPResponseType: HttpServerResponseProtocol>: HandlerProtocol {
    private let _handle: (HTTPRequestType) async throws -> HttpServerResponseBuilder<HTTPResponseType>
    
    public init<InputType, OutputType, HandlerType: HandlerProtocol>(next: HandlerType,
                                                                     initializePhase: OperationMiddlewarePhase<InputType, OutputType>,
                                                                     deserializationTransform: AnyDeserializationTransform<HTTPRequestType, InputType>,
                                                                     serializePhase: SerializeServerResponseMiddlewarePhase<OutputType, HTTPRequestType, HTTPResponseType>)
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        func handle(input: HTTPRequestType) async throws -> HttpServerResponseBuilder<HTTPResponseType> {
            let initialize = initializePhase.compose(next: next)
            let transform = ServerSerializationTransformHandler<InputType, OutputType, HTTPRequestType, HTTPResponseType,
                                                                    AnyHandler<HandlerType.InputType, HandlerType.OutputType>>(
                handler: initialize, deserializationTransform: deserializationTransform)
            let serializeInput = serializePhase.compose(next: transform)
            let handlerOutput = SerializeServerResponsePhaseHandler(handler: serializeInput)
            
            return try await handlerOutput.handle(input: input)
        }
        
        self._handle = handle
    }
    
    public func handle(input: HTTPRequestType) async throws -> HttpServerResponseBuilder<HTTPResponseType> {
        return try await self._handle(input)
    }
}
