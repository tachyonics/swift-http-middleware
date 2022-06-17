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
//  HandlerProtocol.swift
//  swift-http-client-middleware
//

#if compiler(<5.7)
public protocol HandlerProtocol {
    associatedtype Input
    associatedtype Output
       
    func handle(input: Input) async throws -> Output
}

extension HandlerProtocol {
    public func eraseToAnyHandler() -> AnyHandler<Input, Output> {
        return AnyHandler(self)
    }
}
#else
public protocol HandlerProtocol<Input, Output> {
    associatedtype Input
    associatedtype Output
       
    func handle(input: Input) async throws -> Output
}

extension HandlerProtocol {
    public func eraseToAnyHandler() -> any HandlerProtocol<Input, Output> {
        return self
    }
}
#endif
