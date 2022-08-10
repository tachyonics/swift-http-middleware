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
//  HttpServerResponseBuilder.swift
//  HttpServerMiddleware
//
/*
import HttpMiddleware

public class HttpServerResponseBuilder<HTTPResponseType: HttpServerResponseProtocol> {
    
    public typealias HeadersType = HTTPResponseType.HeadersType
    public typealias BodyType = HTTPResponseType.BodyType
    
    public init() {
    }

    public private(set) var headers: HeadersType = HeadersType()
    public private(set) var status: HTTPResponseStatus = .ok
    public private(set) var httpVersion: HTTPVersion = .http1_1
    public private(set) var body: BodyType? = nil
    
    public var additionalResponseProperties: HTTPResponseType.AdditionalResponsePropertiesType?

    // We follow the convention of returning the builder object
    // itself from any configuration methods, and by adding the
    // @discardableResult attribute we won't get warnings if we
    // don't end up doing any chaining.
    @discardableResult
    public func withHeaders(_ value: HeadersType) -> Self {
        self.headers.add(contentsOf: value)
        return self
    }
    
    @discardableResult
    public func withHeader(name: String, value: String) -> Self {
        self.headers.add(name: name, value: value)
        return self
    }
    
    @discardableResult
    public func replaceOrAddHeader(name: String, values: [String]) -> Self {
        self.headers.replaceOrAdd(name: name, values: values)
        return self
    }
    
    @discardableResult
    public func withStatus(_ value: HTTPResponseStatus) -> Self {
        self.status = value
        return self
    }
    
    @discardableResult
    public func withHTTPVersion(_ value: HTTPVersion) -> Self {
        self.httpVersion = value
        return self
    }
    
    @discardableResult
    public func withBody(_ value: BodyType?) -> Self {
        self.body = value
        return self
    }

    public func build() throws -> HTTPResponseType {
        return try HTTPResponseType(headers: self.headers, status: self.status,
                                    httpVersion: self.httpVersion, body: self.body,
                                    additionalResponseProperties: self.additionalResponseProperties)
    }
}
*/
