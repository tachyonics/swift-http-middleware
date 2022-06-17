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
//  HttpMethodType.swift
//  swift-http-client-middleware
//

// this should not be here
public enum HttpMethod: Equatable {
    internal enum HasBody {
        case yes
        case no
        case unlikely
    }

    case GET
    case PUT
    case ACL
    case HEAD
    case POST
    case COPY
    case LOCK
    case MOVE
    case BIND
    case LINK
    case PATCH
    case TRACE
    case MKCOL
    case MERGE
    case PURGE
    case NOTIFY
    case SEARCH
    case UNLOCK
    case REBIND
    case UNBIND
    case REPORT
    case DELETE
    case UNLINK
    case CONNECT
    case MSEARCH
    case OPTIONS
    case PROPFIND
    case CHECKOUT
    case PROPPATCH
    case SUBSCRIBE
    case MKCALENDAR
    case MKACTIVITY
    case UNSUBSCRIBE
    case SOURCE
    case RAW(value: String)

    /// Whether requests with this verb may have a request body.
    internal var hasRequestBody: HasBody {
        switch self {
        case .TRACE:
            return .no
        case .POST, .PUT, .PATCH:
            return .yes
        case .GET, .CONNECT, .OPTIONS, .HEAD, .DELETE:
            fallthrough
        default:
            return .unlikely
        }
    }
}
