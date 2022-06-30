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
//  AnyHandler.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
/// Type erased Handler
public struct AnyHandler<InputType, OutputType>: HandlerProtocol {
    private let _handle: (InputType) async throws -> OutputType
    
    public init<HandlerType: HandlerProtocol> (_ realHandler: HandlerType)
    where HandlerType.InputType == InputType, HandlerType.OutputType == OutputType {
        if let alreadyErased = realHandler as? AnyHandler<InputType, OutputType> {
            self = alreadyErased
            return
        }
        self._handle = realHandler.handle
    }
    
    public func handle(input: InputType) async throws -> OutputType {
        return try await _handle(input)
    }
}
#else
public typealias AnyHandler<MInput, MOutput> = any HandlerProtocol<MInput, MOutput>
#endif
