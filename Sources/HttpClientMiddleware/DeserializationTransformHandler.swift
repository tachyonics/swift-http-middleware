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

public protocol DeserializationTransformProtocol {
    
    func transform<HTTPResponseType, OutputType>(
        input: HTTPResponseType) async throws -> OutputType
}

public struct DeserializationTransformHandler<HTTPResponseType, OutputType, HTTPRequestType: HttpRequestProtocol,
                                              HandlerType: HandlerProtocol>: HandlerProtocol
where HandlerType.Input == HttpRequestBuilder<HTTPRequestType>, HandlerType.Output == HTTPResponseType {

    public typealias Input = HttpRequestBuilder<HTTPRequestType>
    
    public typealias Output = OperationOutput<OutputType, HTTPResponseType>
    
    let handler: HandlerType
    let deserializationTransform: DeserializationTransformProtocol
    
    public init(outputType: OutputType.Type,
                handler: HandlerType,
                deserializationTransform: DeserializationTransformProtocol) {
        self.handler = handler
        self.deserializationTransform = deserializationTransform
    }
    
    public func handle(input: HttpRequestBuilder<HTTPRequestType>) async throws -> Output {
        let httpResponse = try await handler.handle(input: input)
        let transformOutput: OutputType = try await self.deserializationTransform.transform(input: httpResponse)
        
        return OperationOutput(httpResponse: httpResponse, output: transformOutput)
    }
}

public struct OperationOutput<OutputType, HTTPResponseType> {
    public var httpResponse: HTTPResponseType
    public var output: OutputType
    
    public init(httpResponse: HTTPResponseType, output: OutputType) {
        self.httpResponse = httpResponse
        self.output = output
    }
}
