
import Foundation
import Combine

public class ZComNet {

    // MARK: - Properties
    static let logger = Logger()
    public var loglevel: Loglevel {
        get { return ZComNet.logger.level }
        set { ZComNet.logger.level = newValue }
    }

    public struct RequestImage {
        let fileName: String
        let type: ImageType
        let data: Data
        let parameter: String
        let boundary: String

        public init(fileName: String, type: ImageType, data: Data, parameter: String, boundary: String) {
            self.fileName = fileName
            self.type = type
            self.data = data
            self.parameter = parameter
            self.boundary = boundary
        }
    }


    // MARK: - Initialization
    public init(with component: URLComponents, timeout: TimeInterval? = nil, loglevel: Loglevel = .none) {
        self.loglevel = loglevel
        ZComNetService.main.config(with: component, timeout: timeout)
    }

    public func request<T: Codable>(_ endpoint: Endpoint, error: Codable.Type, image: RequestImage? = nil) async -> Result<T, Error> {
        await ZComNetService.main.request(endpoint, error: error, image: image)
    }
}
