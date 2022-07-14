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

import HttpMiddleware

public struct ServerOperationHandler<HandlerType: MiddlewareHandlerProtocol, HTTPRequestType: HttpServerRequestProtocol,
                                     HTTPResponseType: HttpServerResponseProtocol>: MiddlewareHandlerProtocol {
    private let next: HandlerType
    private let middleware: SingleServerOperationMiddlewareStack<HandlerType.InputType, HandlerType.OutputType,
                                                                 HTTPRequestType, HTTPResponseType>
    
    public init(next: HandlerType,
                middleware: SingleServerOperationMiddlewareStack<InputType, OutputType, HTTPRequestType, HTTPResponseType>)
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        self.next = next
        self.middleware = middleware
    }
    
    public func handle(input: HTTPRequestType, context: MiddlewareContext) async throws -> HttpServerResponseBuilder<HTTPResponseType> {
        let initialize = middleware.initializePhase.compose(next: next)
        let transform = ServerSerializationTransformHandler<HandlerType.InputType, HandlerType.OutputType, HTTPRequestType, HTTPResponseType,
                                                                AnyMiddlewareHandler<HandlerType.InputType, HandlerType.OutputType>>(
                                                                    handler: initialize, deserializationTransform: middleware._deserializationTransform)
        let serializeInput = middleware.serializePhase.compose(next: transform)
        let handlerOutput = SerializeServerResponsePhaseHandler(handler: serializeInput)
        
        return try await handlerOutput.handle(input: input, context: context)
    }
}
