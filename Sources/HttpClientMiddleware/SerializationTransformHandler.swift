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
//  SerializationTransformHandler.swift
//  swift-http-client-middleware
//

public struct SerializationTransformHandler<StackInput, StackOutput, HttpRequestType: HttpRequestProtocol,
                                                          HandlerType: HandlerProtocol>: HandlerProtocol
where HandlerType.Input == HttpRequestBuilder<HttpRequestType>, HandlerType.Output == StackOutput {

    public typealias Input = StackInput
    
    public typealias Output = StackOutput
    
    let handler: HandlerType
    let serializationTransform:
        AnyTransform<SerializationTransformInput<StackInput, HttpRequestType>, HttpRequestBuilder<HttpRequestType>>
    
    public init(serializationTransform:
                    AnyTransform<SerializationTransformInput<StackInput, HttpRequestType>, HttpRequestBuilder<HttpRequestType>>,
                handler: HandlerType) {
        self.handler = handler
        self.serializationTransform = serializationTransform
    }
    
    public func handle(input: StackInput) async throws -> Output {
        let serializationInput = SerializationTransformInput<StackInput, HttpRequestType>(operationInput: input)
        let serializationOutput = try await self.serializationTransform.transform(input: serializationInput)
        
        return try await handler.handle(input: serializationOutput)
    }
}
