//
//  File.swift
//  
//
//  Created by Simon Zwicker on 27.03.24.
//

import Foundation

final class Logger {

    // MARK: - Properties
    var level: Loglevel = .none
    private let dateFormatter = DateFormatter()
    private var request: URLRequest? = nil
    private var start: Date = .init()
    private var end: Date = .init()

    // MARK: - Log
    func log(_ request: URLRequest) {
        guard level != .none else { return }
        self.request = request

        self.start = Date()
        print("--------------- [ZComNet] - Logging Start ---------------")
        logBasic()
    }

    func log(_ response: URLResponse, data: Data) {
        guard level != .none else { return }
        if let response = response as? HTTPURLResponse {
            logStatusCodeURL(response)
        }

        if level == .debug {
            print("[\(currentTime())][ZComNet][Response]:")
            print(String(decoding: data, as: UTF8.self))
        }

        self.end = Date()
        print("[\(currentTime())][ZComNet][Call Duration]: \(getCallTime())")
        print("---------------- [ZComNet] - Logging End ----------------")
    }

    // MARK: - Private Helpers
    private func currentTime() -> String {
        self.dateFormatter.dateFormat = "HH:mm:ss"
        return dateFormatter.string(from: Date())
    }

    private func getCallTime() -> String {
        let seconds = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
        return "\(seconds) s"
    }

    private func logBasic() {
        logUrl()
        logHeaders()
        logBody()
    }

    private func logUrl() {
        guard let method = request?.httpMethod, let url = request?.url else { return }
        print("[\(currentTime())][ZComNet][RequestMethod]: \(method)")
        print("[\(currentTime())][ZComNet][URL]: \(url.absoluteString)")
    }

    private func logHeaders() {
        guard let headerFields = request?.allHTTPHeaderFields else { return }
        print("[\(currentTime())][ZComNet][Headers]:")
        headerFields.forEach {
            print("----- \($0.key): \($0.value)")
        }
    }

    private func logBody() {
        guard let body = request?.httpBody, let string = String(data: body, encoding: .utf8) else { return }
        print("[\(currentTime())][ZComNet][Body]:")
        print(body)
    }

    private func logStatusCodeURL(_ response: HTTPURLResponse) {
        print("[\(currentTime())][ZComNet][StatusCode]: \(response.statusCode)")
    }

    private func logCurl() {
        guard let curl = request?.curl() else { return }
        print("[\(currentTime())][ZComNet][Curl Command]: \(curl)")
    }
}
