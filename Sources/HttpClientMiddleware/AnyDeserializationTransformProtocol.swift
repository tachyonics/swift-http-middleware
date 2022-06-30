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
//  AnyDeserializationTransform.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
/// Type erased DeserializationTransform
public struct AnyDeserializationTransform<HTTPResponseType: HttpResponseProtocol, OutputType>: DeserializationTransformProtocol {
    private let _handle: (HTTPResponseType) async throws -> OutputType
    
    public init<DeserializationTransformType: DeserializationTransformProtocol> (_ realDeserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.HTTPResponseType == HTTPResponseType, DeserializationTransformType.OutputType == OutputType {
        if let alreadyErased = realDeserializationTransform as? AnyDeserializationTransform<HTTPResponseType, OutputType> {
            self = alreadyErased
            return
        }
        self._handle = realDeserializationTransform.transform
    }
    
    public func transform(
        input: HTTPResponseType) async throws -> OutputType {
        return try await _handle(input)
    }
}
#else
public typealias AnyDeserializationTransform<MInput, MOutput> = any DeserializationTransformProtocol<MInput, MOutput>
#endif
