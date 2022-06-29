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
//  AnyTransform.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
/// type erase the Transform protocol
public struct AnyTransform<TInput, TOutput>: TransformProtocol {
    
    private let _transform: (TInput) async throws -> TOutput

    public init<T: TransformProtocol>(_ realTransform: T)
    where T.TInput == TInput, T.TOutput == TOutput {
        if let alreadyErased = realTransform as? AnyTransform<TInput, TOutput> {
            self = alreadyErased
            return
        }

        self._transform = realTransform.transform
    }

    public func transform(input: TInput) async throws -> TOutput {
        return try await _transform(input)
    }
}
#else
public typealias AnyTransform<TInput, TOutput> = any TransformProtocol<TInput, TOutput>
#endif
