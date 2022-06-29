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
//  TransformProtocol.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
public protocol TransformProtocol {
    associatedtype TInput
    associatedtype TOutput
    
    func transform(input: TInput) async throws -> TOutput
}

extension TransformProtocol {
    public func eraseToAnyTransform() -> AnyTransform<TInput, TOutput> {
        return AnyTransform(self)
    }
}
#else
public protocol TransformProtocol<TInput, TOutput> {
    associatedtype TInput
    associatedtype TOutput
    
    func handle(input: TInput) async throws -> TOutput
}

extension TransformProtocol {
    public func eraseToAnyTransform() -> any TransformProtocol<TInput, TOutput> {
        return self
    }
}
#endif
