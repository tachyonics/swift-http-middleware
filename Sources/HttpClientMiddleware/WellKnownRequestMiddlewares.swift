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
//  WellKnownRequestMiddlewares.swift
//  swift-http-client-middleware
//

public protocol UserAgentRequestMiddlewareProtocol: RequestMiddlewareProtocol {
    
}

public extension UserAgentRequestMiddlewareProtocol {
    var id: String {
        "UserAgentHeader"
    }
}

public protocol AcceptRequestMiddlewareProtocol: RequestMiddlewareProtocol {
    
}

public extension AcceptRequestMiddlewareProtocol {
    var id: String {
        "AcceptHeader"
    }
}

public protocol RetryerRequestMiddlewareProtocol: RequestMiddlewareProtocol {
    
}

public extension RetryerRequestMiddlewareProtocol {
    var id: String {
        "Retryer"
    }
}

public protocol ContentLengthRequestMiddlewareProtocol: RequestMiddlewareProtocol {
    
}

public extension ContentLengthRequestMiddlewareProtocol {
    var id: String {
        "ContentLength"
    }
}

public protocol ContentTypeRequestMiddlewareProtocol: RequestMiddlewareProtocol {
    
}

public extension ContentTypeRequestMiddlewareProtocol {
    var id: String {
        "ContentType"
    }
}
