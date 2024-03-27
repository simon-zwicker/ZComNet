
import Foundation
import Combine

public class ZComNet {

    // MARK: - Properties
    static let logger = Logger()
    public var loglevel: Loglevel {
        get { return ZComNet.logger.level }
        set { ZComNet.logger.level = newValue }
    }

    // MARK: - Initialization
    public init(with component: URLComponents, timeout: TimeInterval? = nil, loglevel: Loglevel = .none) {
        self.loglevel = loglevel
        ZComNetService.main.config(with: component, timeout: timeout)
    }

    public func request<T: Codable>(_ endpoint: Endpoint, error: Codable.Type) async -> Result<T, Error> {
        await ZComNetService.main.request(endpoint, error: error)
    }
}
