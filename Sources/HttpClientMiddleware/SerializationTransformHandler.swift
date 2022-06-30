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

#if compiler(<5.7)
public protocol SerializationTransformProtocol {
    associatedtype HTTPRequestType: HttpRequestProtocol
    associatedtype InputType
    
    func transform(
        input: SerializationTransformInput<InputType, HTTPRequestType>) async throws -> HttpRequestBuilder<HTTPRequestType>
}

extension SerializationTransformProtocol {
    public func eraseToAnySerializationTransform() -> AnySerializationTransform<InputType, HTTPRequestType> {
        return AnySerializationTransform(self)
    }
}

public protocol DeserializationTransformProtocol {
    associatedtype HTTPResponseType: HttpResponseProtocol
    associatedtype OutputType
    
    func transform(
        input: HTTPResponseType) async throws -> OutputType
}

extension DeserializationTransformProtocol {
    public func eraseToAnyDeserializationTransform() -> AnyDeserializationTransform<HTTPResponseType, OutputType> {
        return AnyDeserializationTransform(self)
    }
}
#else
public protocol SerializationTransformProtocol {
    associatedtype HTTPRequestType: HttpRequestProtocol
    associatedtype InputType
    
    func transform(
        input: SerializationTransformInput<InputType, HTTPRequestType>) async throws -> HttpRequestBuilder<HTTPRequestType>
}

extension SerializationTransformProtocol {
    public func eraseToAnySerializationTransform() -> any SerializationTransform<InputType, HTTPRequestType> {
        return self
    }
}

public protocol DeserializationTransformProtocol {
    associatedtype HTTPResponseType: HttpResponseProtocol
    associatedtype OutputType
    
    func transform(
        input: HTTPResponseType) async throws -> OutputType
}

extension SerializationTransformProtocol {
    public func eraseToAnyDeserializationTransform() -> any DeserializationTransform<HTTPResponseType, OutputType> {
        return self
    }
}
#endif

public struct SerializationTransformHandler<InputType, OutputType, HTTPRequestType: HttpRequestProtocol,
                                            HTTPResponseType: HttpResponseProtocol, HandlerType: HandlerProtocol>: HandlerProtocol
where HandlerType.InputType == HttpRequestBuilder<HTTPRequestType>, HandlerType.OutputType == HTTPResponseType {

    public typealias Input = InputType
    
    public typealias Output = OutputType
    
    let handler: HandlerType
    let serializationTransform: AnySerializationTransform<InputType, HTTPRequestType>
    let deserializationTransform: AnyDeserializationTransform<HTTPResponseType, OutputType>
    
    public init<SerializationTransformType: SerializationTransformProtocol, DeserializationTransformType: DeserializationTransformProtocol>(
                serializationTransform: SerializationTransformType,
                handler: HandlerType,
                deserializationTransform: DeserializationTransformType)
    where SerializationTransformType.InputType == InputType, SerializationTransformType.HTTPRequestType == HTTPRequestType,
          DeserializationTransformType.HTTPResponseType == HTTPResponseType, DeserializationTransformType.OutputType == OutputType {
        self.handler = handler
        self.serializationTransform = serializationTransform.eraseToAnySerializationTransform()
              self.deserializationTransform = deserializationTransform.eraseToAnyDeserializationTransform()
    }
    
    public func handle(input: InputType) async throws -> Output {
        let serializationInput = SerializationTransformInput<InputType, HTTPRequestType>(operationInput: input)
        let serializationOutput = try await self.serializationTransform.transform(input: serializationInput)
        
        let httpResponse = try await handler.handle(input: serializationOutput)
        return try await self.deserializationTransform.transform(input: httpResponse)
    }
}
