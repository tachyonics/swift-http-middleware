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
//  OperationMiddlewareStack.swift
//  swift-http-client-middleware
//

public let InitializePhaseId = "Initialize"
public let SecondFinalizePhaseId = "SecondFinalize"
/*
public struct OperationMiddlewareStack {
    public var serializationTransform: SerializationTransformProtocol
    public var deserializationTransform: DeserializationTransformProtocol
    
    /// returns the unique id for the operation stack as middleware
    public var id: String
    public var initializePhase: TypedInputOutputPhase
    public var buildPhase: HttpRequestBuildPhase
    public var finalizePhase: HttpRequestBuildPhase
    public var secondFinalizePhase: HttpRequestBuildPhase
    
    public init(
        id: String, serializationTransform: SerializationTransformProtocol, deserializationTransform: DeserializationTransformProtocol)
    {
        self.id = id
        self.initializePhase = TypedInputOutputPhase(id: InitializePhaseId)
        self.buildPhase = HttpRequestBuildPhase(id: BuildPhaseId)
        self.finalizePhase = HttpRequestBuildPhase(id: FinalizePhaseId)
        self.secondFinalizePhase = HttpRequestBuildPhase(id: SecondFinalizePhaseId)
        self.serializationTransform = serializationTransform
        self.deserializationTransform = deserializationTransform
    }
    
    /// This execute will execute the stack and use your next as the last closure in the chain
    public func handleMiddleware<HandlerType: HandlerProtocol,
                                 StackInput, StackOutput, HTTPRequestType: HttpRequestProtocol, HTTPResponseType>(
                                             input: StackInput,
                                             next: HandlerType) async throws -> StackOutput
    where HandlerType.Input == HttpRequestBuilder<HTTPRequestType>, HandlerType.Output == HTTPResponseType {
        let secondFinalize = secondFinalizePhase.compose(next: next)
        let deserialise = DeserializationTransformHandler(outputType: StackOutput.self,
                                                          handler: secondFinalize, deserializationTransform: self.deserializationTransform)
        let finalize = compose(next: FinalizePhaseHandler(handler: deserialise), with: finalizePhase)
        let build = compose(next: BuildPhaseHandler(handler: finalize), with: buildPhase)
        let serialize = SerializationTransformHandler(serializationTransform: self.serializationTransform, handler: build)
        let initialize = compose(next: InitializePhaseHandler(handler: serialize), with: initializePhase)
              
        return try await initialize.handle(input: input).output
    }
    
    mutating public func presignedRequest<HandlerType: HandlerProtocol>(
                                                      input: StackInput,
                                                      next: HandlerType) async throws -> StackInput
    where HandlerType.Input == HttpRequestBuilder<HTTPRequestType>,
          HandlerType.Output == HTTPResponseType {
        _ = try await handleMiddleware(input: input, next: next)
        return input
    }
}*/
