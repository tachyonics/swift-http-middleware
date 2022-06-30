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
//  AnySerializationTransform.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
/// Type erased SerializationTransform
public struct AnySerializationTransform<InputType, HTTPRequestType: HttpRequestProtocol>: SerializationTransformProtocol {
    private let _handle: (SerializationTransformInput<InputType, HTTPRequestType>) async throws -> HttpRequestBuilder<HTTPRequestType>
    
    public init<SerializationTransformType: SerializationTransformProtocol> (_ realSerializationTransform: SerializationTransformType)
    where SerializationTransformType.InputType == InputType, SerializationTransformType.HTTPRequestType == HTTPRequestType {
        if let alreadyErased = realSerializationTransform as? AnySerializationTransform<InputType, HTTPRequestType> {
            self = alreadyErased
            return
        }
        self._handle = realSerializationTransform.transform
    }
    
    public func transform(
        input: SerializationTransformInput<InputType, HTTPRequestType>) async throws -> HttpRequestBuilder<HTTPRequestType> {
        return try await _handle(input)
    }
}
#else
public typealias AnySerializationTransform<MInput, MOutput> = any SerializationTransformProtocol<MInput, MOutput>
#endif
