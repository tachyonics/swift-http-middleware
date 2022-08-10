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
//  WellKnownMiddlewares.swift
//  HttpClientMiddleware
//

import SwiftMiddleware

public protocol LoggerMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension LoggerMiddlewareProtocol {
    var id: String {
        "Logger"
    }
}

public protocol ContentLengthMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension ContentLengthMiddlewareProtocol {
    var id: String {
        "ContentLength"
    }
}


public protocol ContentTypeMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension ContentTypeMiddlewareProtocol {
    var id: String {
        "ContentType"
    }
}


public protocol BodyMiddlewareProtocol: MiddlewareProtocol {
    
}

public extension BodyMiddlewareProtocol {
    var id: String {
        "Body"
    }
}
