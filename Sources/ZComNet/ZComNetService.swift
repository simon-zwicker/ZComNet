//
//  File.swift
//  
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation
import Combine

final class ZComNetService {

    // MARK: - Properties
    static let main = ZComNetService()
    private var baseUrl: URL?
    private var baseUrlString: String?
    private var components: URLComponents?
    private var timeout: TimeInterval?

    // MARK: - Configurations
    func config(with components: URLComponents, timeout: TimeInterval?) {
        self.baseUrl = components.url
        self.baseUrlString = components.string
        self.timeout = timeout
        self.components = components
    }

    func request<T: Codable>(_ endpoint: Endpoint, error: Codable.Type) async -> Result<T, Error> {

        guard let request = try? await createRequest(for: endpoint) else { return .failure(ErrorType.invalidUrl) }
        let session = URLSession.shared

        do {
            let (data, response) = try await session.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else { return .failure(ErrorType.noResponse) }

            /// Logger
            ZComNet.logger.log(response, data: data)

            switch response.statusCode {
            case 200...299:
                guard let decoded = try? data.decode(T.self) else { return .failure(ErrorType.decode) }
                return .success(decoded)

            case 401:
                guard let decoded = try? data.decode(error) else { return .failure(ErrorType.decode) }
                return .failure(ErrorType.unauthorized(decoded))

            case 404:
                guard let decoded = try? data.decode(error) else { return .failure(ErrorType.decode) }
                return .failure(ErrorType.noData(decoded))

            default:
                guard let decoded = try? data.decode(error) else { return .failure(ErrorType.decode) }
                return .failure(ErrorType.unexpectedStatusCode(decoded))
            }
        } catch {
            return .failure(ErrorType.unknown)
        }
    }

}

// MARK: - Extension
extension ZComNetService {

    private func createRequest(for endpoint: Endpoint) async throws -> URLRequest {
        /// Create Request Object
        guard let url = try? await getUrl(for: endpoint) else { throw ErrorType.invalidUrl }
        var request = URLRequest(url: url)

        /// Request Body
        if endpoint.encoding == .json, endpoint.parameters.isNotEmpty {
            request.httpBody = encodeJson(params: endpoint.parameters)
        }

        /// Request Method & Headers
        request.httpMethod = endpoint.method.rawValue
        endpoint.headers.forEach({ request.setValue($0.value, forHTTPHeaderField: $0.key) })

        /// Logger
        ZComNet.logger.log(request)

        return request
    }

    private func getUrl(for endpoint: Endpoint) async throws -> URL {
        guard var components else { throw ErrorType.invalidUrl }

        if endpoint.parameters.isNotEmpty, endpoint.encoding == .url {
            components.queryItems = encodeUrl(params: endpoint.parameters)
        }

        components.path += endpoint.path

        guard let baseUrlString = components.url?.absoluteString, let url = URL(string: baseUrlString) else {
            throw ErrorType.invalidUrl
        }

        return url
    }

    private func encodeUrl(params: [String: Any]) -> [URLQueryItem] {
        return params.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
    }

    private func encodeJson(params: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: params, options: [])
    }
}
