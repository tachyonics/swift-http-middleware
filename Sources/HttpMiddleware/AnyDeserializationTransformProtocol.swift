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
//  HttpMiddleware
//

#if compiler(<5.7)
/// Type erased DeserializationTransform
public struct AnyDeserializationTransform<InputType, OutputType, ContextType>: DeserializationTransformProtocol {
    private let _handle: (InputType, ContextType) async throws -> OutputType
    
    public init<DeserializationTransformType: DeserializationTransformProtocol> (_ realDeserializationTransform: DeserializationTransformType)
    where DeserializationTransformType.InputType == InputType, DeserializationTransformType.OutputType == OutputType,
    DeserializationTransformType.ContextType == ContextType {
        if let alreadyErased = realDeserializationTransform as? AnyDeserializationTransform<InputType, OutputType, ContextType> {
            self = alreadyErased
            return
        }
        self._handle = realDeserializationTransform.transform
    }
    
    public func transform(
        input: InputType, context: ContextType) async throws -> OutputType {
        return try await _handle(input, context)
    }
}
#else
public typealias AnyDeserializationTransform<MInput, MOutput> = any DeserializationTransformProtocol<MInput, MOutput>
#endif
