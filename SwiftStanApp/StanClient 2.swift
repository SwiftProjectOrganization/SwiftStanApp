import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

enum StanClient {
  /// Build a generated Client with a generous timeout for long-running
  /// cmdstan operations (sampling can take many minutes).
  static func make() -> Client {
    var config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 900
    config.timeoutIntervalForResource = 900
    return Client(
      serverURL: ServerSettings.serverURL(),
      transport: URLSessionTransport(configuration: .init(session: URLSession(configuration: config))))
  }
}
