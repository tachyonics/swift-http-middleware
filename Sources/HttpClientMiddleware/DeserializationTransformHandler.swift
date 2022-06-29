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
//  DeserializationTransformHandler.swift
//  swift-http-client-middleware
//

public struct DeserializationTransformHandler<HTTPResponseType, StackOutput, HttpRequestType: HttpRequestProtocol,
                                              HandlerType: HandlerProtocol>: HandlerProtocol
where HandlerType.Input == HttpRequestBuilder<HttpRequestType>, HandlerType.Output == HTTPResponseType {

    public typealias Input = HttpRequestBuilder<HttpRequestType>
    
    public typealias Output = OperationOutput<StackOutput, HTTPResponseType>
    
    let handler: HandlerType
    let deserializationTransform: AnyTransform<HTTPResponseType, StackOutput>
    
    public init(handler: HandlerType,
                deserializationTransform: AnyTransform<HTTPResponseType, StackOutput>) {
        self.handler = handler
        self.deserializationTransform = deserializationTransform
    }
    
    public func handle(input: HttpRequestBuilder<HttpRequestType>) async throws -> Output {
        let httpResponse = try await handler.handle(input: input)
        let transformOutput = try await self.deserializationTransform.transform(input: httpResponse)
        
        return OperationOutput(httpResponse: httpResponse, output: transformOutput)
    }
}

public struct OperationOutput<StackOutput, HTTPResponseType> {
    public var httpResponse: HTTPResponseType
    public var output: StackOutput
    
    public init(httpResponse: HTTPResponseType, output: StackOutput) {
        self.httpResponse = httpResponse
        self.output = output
    }
}
