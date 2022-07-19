//
//  HTTPClient.swift
//  
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public protocol HTTPClient: AnyObject {
    func sendRequest<T: Decodable>(session: URLSession,
                                   endpoint: Endpoint,
                                   responseModel: T.Type) async -> Result<T, HTTPRequestError>
}

public extension HTTPClient {
    func sendRequest<T: Decodable>(session: URLSession = .shared,
                                   endpoint: Endpoint,
                                   responseModel: T.Type) async -> Result<T, HTTPRequestError> {
        guard let url = endpoint.url else {
            return .failure(.invalidURL)
        }
        var request: URLRequest = .init(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = endpoint.header
        if let body = endpoint.body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
#if DEBUG
        request.debug()
#endif
        do {
            let (data, response) = try await session.data(for: request)
            guard let responseCode = (response as? HTTPURLResponse)?.statusCode else {
                return .failure(.noResponse)
            }
            switch responseCode {
            case 200...299:
                if let decodeData = data.decode(model: responseModel) {
                    return .success(decodeData)
                } else {
                    return .failure(.decode)
                }
            case 401: return .failure(.unauthorizate)
            case 422:
                if let validatorErrorData = data.decode(model: ValidatorErrorResponse.self) {
                    return .failure(.validator(detail: validatorErrorData.detail[0]))
                } else {
                    return .failure(.decode)
                }
            default:
                if let errorData = data.decode(model: DefaultErrorResponse.self) {
                    return .failure(.defaultServerError(error: errorData.detail))
                }
                return .failure(.unexpectedStatusCode(code: responseCode,
                                                      localized: responseCode.localStatusCode))
            }
        } catch {
            return .failure(.request(localizedDiscription: error.localizedDescription))
        }
    }
}
