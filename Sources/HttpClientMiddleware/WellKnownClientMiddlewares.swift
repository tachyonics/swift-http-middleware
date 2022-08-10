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
//  WellKnownClientMiddlewares.swift
//  HttpClientMiddleware
//

import SwiftMiddleware

public protocol AcceptHeaderMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension AcceptHeaderMiddlewareProtocol {
    var id: String {
        "AcceptHeader"
    }
}


public protocol QueryItemMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension QueryItemMiddlewareProtocol {
    var id: String {
        "QueryItem"
    }
}


public protocol RequestRetryerMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension RequestRetryerMiddlewareProtocol {
    var id: String {
        "Retryer"
    }
}


public protocol RequestURLHostMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension RequestURLHostMiddlewareProtocol {
    var id: String {
        "URLHost"
    }
}

public protocol RequestURLProtocolTypeMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension RequestURLProtocolTypeMiddlewareProtocol {
    var id: String {
        "URLProtocolType"
    }
}

public protocol RequestMethodMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension RequestMethodMiddlewareProtocol {
    var id: String {
        "Method"
    }
}

public protocol RequestURLPortMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension RequestURLPortMiddlewareProtocol {
    var id: String {
        "URLPort"
    }
}


public protocol RequestURLPathMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension RequestURLPathMiddlewareProtocol {
    var id: String {
        "URLPath"
    }
}

public protocol UserAgentHeaderMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension UserAgentHeaderMiddlewareProtocol {
    var id: String {
        "UserAgentHeader"
    }
}
