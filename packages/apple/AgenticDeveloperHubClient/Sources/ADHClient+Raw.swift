import HTTPTypes
import OpenAPIRuntime

#if canImport(FoundationEssentials)
import FoundationEssentials
#else
import Foundation
#endif

public struct RawResponse: Sendable {
    public let status: Int
    public let headers: [String: String]
    public let body: Data

    public func decode<T: Decodable>(_ type: T.Type, decoder: JSONDecoder = .adhDefault) throws -> T {
        try decoder.decode(type, from: body)
    }
}

public enum RawRequestError: Error, Sendable, Equatable {
    case invalidPath(String)
    case http(status: Int, body: Data)
}

extension JSONDecoder {
    /// ISO-8601 with or without fractional seconds — what the hub backend emits.
    public static let adhDefault: JSONDecoder = {
        let decoder = JSONDecoder()
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            if let date = fractional.date(from: text) ?? plain.date(from: text) { return date }
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "not an ISO-8601 date: \(text)"))
        }
        return decoder
    }()
}

/// The one buffering cap for a whole-body read on the request path. Both the
/// request body `SessionRefreshMiddleware` buffers (so a retry can resend it)
/// and the response body `rawJSON` collects are governed by this single
/// contract: 16 MiB covers every JSON body the hub sends; uploads go through
/// storage presigned URLs, not this client.
enum ADHBodyLimit {
    static let maxBuffered = 16 * 1024 * 1024
}

/// Escape hatch for backend routes the OpenAPI document does not describe, or
/// describes stalely enough that the generated operation cannot express
/// the real request (see the design spec's endpoint inventory). Runs the exact
/// middleware chain the typed `api` uses, so bearer injection and
/// refresh-and-retry apply identically.
extension ADHClient {

    /// The `operationID` `rawJSON` reports to the middleware chain for a raw
    /// request. Middleware that keys off operation IDs (notably
    /// ``SessionRefreshMiddleware/exemptOperationIDs``) must derive its
    /// entries from this, never restate the format, so the two can never
    /// disagree about what a raw request is called.
    static func rawOperationID(method: HTTPRequest.Method, path: String) -> String {
        "raw \(method.rawValue) \(path)"
    }

    /// `POST /auth/revoke` — the one raw route the session layer itself sends
    /// (from ``signOut()``). Named here so `signOut` and the refresh
    /// middleware's exemption always describe the same request.
    static let revokeMethod: HTTPRequest.Method = .post
    static let revokePath = "/auth/revoke"
    static let revokeRawOperationID = rawOperationID(method: revokeMethod, path: revokePath)

    public func rawJSON(
        method: HTTPRequest.Method,
        path: String,
        query: [String: String] = [:],
        body: Data? = nil
    ) async throws -> RawResponse {
        guard path.hasPrefix("/") else { throw RawRequestError.invalidPath(path) }

        var fullPath = path
        if !query.isEmpty {
            let allowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "+&=?#"))
            let encoded = query
                .sorted { $0.key < $1.key }
                .map { key, value in
                    let k = key.addingPercentEncoding(withAllowedCharacters: allowed) ?? key
                    let v = value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
                    return "\(k)=\(v)"
                }
                .joined(separator: "&")
            fullPath += (path.contains("?") ? "&" : "?") + encoded
        }

        var request = HTTPRequest(method: method, scheme: nil, authority: nil, path: fullPath)
        request.headerFields[.accept] = "application/json"
        if body != nil {
            request.headerFields[.contentType] = "application/json"
        }

        let operationID = Self.rawOperationID(method: method, path: path)
        let transport = self.transport
        var next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?) = { request, body, baseURL in
            try await transport.transport.send(request, body: body, baseURL: baseURL, operationID: operationID)
        }
        for middleware in middlewares.reversed() {
            let tail = next
            next = { request, body, baseURL in
                try await middleware.intercept(request, body: body, baseURL: baseURL, operationID: operationID, next: tail)
            }
        }

        let (response, responseBody) = try await next(request, body.map { HTTPBody($0) }, transport.serverURL)
        let data: Data = if let responseBody {
            try await Data(collecting: responseBody, upTo: ADHBodyLimit.maxBuffered)
        } else {
            Data()
        }
        var headers: [String: String] = [:]
        for field in response.headerFields {
            headers[field.name.canonicalName] = field.value
        }
        guard response.status.code < 400 else {
            throw RawRequestError.http(status: response.status.code, body: data)
        }
        return RawResponse(status: response.status.code, headers: headers, body: data)
    }
}
