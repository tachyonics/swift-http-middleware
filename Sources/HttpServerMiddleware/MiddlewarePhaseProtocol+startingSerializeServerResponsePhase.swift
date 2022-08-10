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
//  MiddlewarePhaseProtocol+startingFinalisePhase.swift
//  HttpServerMiddleware
//

import SwiftMiddleware
import HttpMiddleware

public extension MiddlewarePhaseProtocol {
    func startingSerializeServerResponsePhase<MiddlewareType: MiddlewareProtocol,
                                              DeserializationTransformType: DeserializationTransformProtocol,
                                              HttpRequestType: HttpServerRequestProtocol,
                                              ResponseBuilderType: HttpServerResponseBuilderProtocol>(
        with middleware: MiddlewareType,
        deserializationTransform: DeserializationTransformType)
    -> some MiddlewarePhaseProtocol
    where MiddlewareType.InputType == HttpRequestType,
    MiddlewareType.OutputType == SerializeServerResponseMiddlewarePhaseOutput<OutputType, ResponseBuilderType>,
    DeserializationTransformType.InputType == HttpRequestType,
    DeserializationTransformType.OutputType == InputType,
    DeserializationTransformType.ContextType == MiddlewareContext {
        let oldPhaseHandler = ComposedMiddlewarePhaseHandler(next: self.next, with: self.with)
        
        let transform = ServerSerializationTransformHandler(handler: oldPhaseHandler,
                                                            deserializationTransform: deserializationTransform,
                                                            responseBuilderType: ResponseBuilderType.self)
                
        return MiddlewarePhase(next: transform, with: middleware)
    }
}
