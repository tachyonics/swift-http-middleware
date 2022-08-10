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
//  HttpServerResponseBuilderProtocol.swift
//  HttpServerMiddleware
//

import HttpMiddleware

public protocol HttpServerResponseBuilderProtocol {
    associatedtype HTTPResponseType: HttpServerResponseProtocol
    
    typealias HeadersType = HTTPResponseType.HeadersType
    typealias BodyType = HTTPResponseType.BodyType

    var headers: HeadersType { get }
    var status: HTTPResponseStatus { get }
    var httpVersion: HTTPVersion { get }
    var body: BodyType? { get }
    
    init()
    
    var additionalResponseProperties: HTTPResponseType.AdditionalResponsePropertiesType? { get }

    @discardableResult
    func withHeaders(_ value: HeadersType) -> Self
    
    @discardableResult
    func withHeader(name: String, value: String) -> Self
    
    @discardableResult
    func replaceOrAddHeader(name: String, values: [String]) -> Self
    
    @discardableResult
    func withStatus(_ value: HTTPResponseStatus) -> Self
    
    @discardableResult
    func withHTTPVersion(_ value: HTTPVersion) -> Self
    
    @discardableResult
    func withBody(_ value: BodyType?) -> Self
    
    func build() throws -> HTTPResponseType
}
