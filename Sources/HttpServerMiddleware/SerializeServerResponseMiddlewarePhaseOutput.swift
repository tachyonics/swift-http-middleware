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
//  SerializeServerResponseMiddlewarePhaseOutput.swift
//  HttpServerMiddleware
//

public struct SerializeServerResponseMiddlewarePhaseOutput<OperationResponseType, HTTPResponseBuilderType: HttpServerResponseBuilderProtocol> {
    // the operational response can be nil if a response was created without actually calling the operation
    public let operationResponse: OperationResponseType?
    public let builder: HTTPResponseBuilderType
    
    public init(operationResponse: OperationResponseType? = nil,
                builder: HTTPResponseBuilderType = .init()) {
        self.operationResponse = operationResponse
        self.builder = builder
    }
}
