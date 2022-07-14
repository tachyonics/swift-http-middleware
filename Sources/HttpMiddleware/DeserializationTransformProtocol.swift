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
//  HttpMiddleware
//

#if compiler(<5.7)
public protocol DeserializationTransformProtocol {
    associatedtype InputType
    associatedtype OutputType
    associatedtype ContextType
    
    func transform(
        input: InputType, context: ContextType) async throws -> OutputType
}

extension DeserializationTransformProtocol {
    public func eraseToAnyDeserializationTransform() -> AnyDeserializationTransform<InputType, OutputType, ContextType> {
        return AnyDeserializationTransform(self)
    }
}
#else
public protocol DeserializationTransformProtocol {
    associatedtype HTTPResponseType: HttpClientResponseProtocol
    associatedtype OutputType
    
    func transform(
        input: HTTPResponseType) async throws -> OutputType
}

extension SerializationTransformProtocol {
    public func eraseToAnyDeserializationTransform() -> any DeserializationTransform<InputType, OutputType, ContextType> {
        return self
    }
}
#endif
