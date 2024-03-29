//
//  File.swift
//  
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation
import Combine

final class ZComNetService: NSObject {

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

    func request<T: Codable>(_ endpoint: Endpoint, error: Codable.Type, image: ZComNet.RequestImage? = nil) async -> Result<T, Error> {

        guard let request = try? await createRequest(for: endpoint, image: image) else {
            return .failure(ErrorType.invalidUrl)
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)

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

// MARK: - URLSessionDelegate
extension ZComNetService: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            if challenge.protectionSpace.serverTrust == nil {
                completionHandler(.useCredential, nil)
            } else {
                guard ZComNet.isInsecure, let trust: SecTrust = challenge.protectionSpace.serverTrust else { return }
                let credential = URLCredential(trust: trust)
                completionHandler(.useCredential, credential)
            }
        }
}

// MARK: - Extension
extension ZComNetService {

    private func createRequest(for endpoint: Endpoint, image: ZComNet.RequestImage? = nil) async throws -> URLRequest {
        /// Create Request Object
        guard let url = try? await getUrl(for: endpoint) else { throw ErrorType.invalidUrl }
        var request = URLRequest(url: url)

        /// Request Body
        if endpoint.encoding == .json, endpoint.parameters.isNotEmpty {
            request.httpBody = encodeJson(endpoint.parameters)
        } else if endpoint.encoding == .image, let image {
            request.httpBody = encodeImage(image)
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
            components.queryItems = encodeUrl(endpoint.parameters)
        }

        components.path += endpoint.path

        guard let baseUrlString = components.url?.absoluteString, let url = URL(string: baseUrlString) else {
            throw ErrorType.invalidUrl
        }

        return url
    }

    private func encodeUrl(_ params: [String: Any]) -> [URLQueryItem] {
        return params.map { URLQueryItem(name: $0.key, value: $0.value as? String) }
    }

    private func encodeJson(_ object: [String: Any]) -> Data? {
        return try? JSONSerialization.data(withJSONObject: object, options: [])
    }

    private func encodeImage(_ image: ZComNet.RequestImage) -> Data {
        var fullData: Data = .init()

        if let data = ImageEncoder.boundary(image.boundary).data {
            fullData.append(data)
        }

        if let data = ImageEncoder.contentDisposition(params: image.parameter, filename: image.fileName).data {
            fullData.append(data)
        }

        if let data = ImageEncoder.contentType("image/\(image.type.rawValue)").data {
            fullData.append(data)
        }

        fullData.append(image.data)

        if let data = ImageEncoder.boundary(image.boundary).data {
            fullData.append(data)
        }

        return fullData
    }
}
