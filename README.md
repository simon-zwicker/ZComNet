# ZComNet

Simple lightweight Library for Swift REST API calls async/await

| Minimum Target |    OS      |
| -------------- | --------- |
| 16.0 | iOS |
| 13.0 | macOS |

## Installation

You can install this over the Swift Package Manager

### Xcode User Interface

Go to your Project Settings -> Swift Packages, Insert the GitHub Link of this Repository and click **Add Package**

### Integrate in Package.swift

Without Xcode integration, you can add the following to the dependencies in your `Package.swift`:

```swift
dependencies: [
	.package(url: "https://github.com/simon-zwicker/ZComNet.git")
],

```

## Integration

Following gives you an overview how you can integrate this in your Project. It is just an example of one way to do it.

### Endpoint Enum

```swift
import Foundation
import ZComNet

enum APIEndpoint: Endpoint {
    case todos
    case todo(UUID)
    
    // MARK: - Path
    var path: String {
        switch self {
        case .todos: "/todos"
        case .todo(let id): "/todos/\(id.uuidString)"
        }
    }

    // MARK: - RequestMethod
    var method: RequestMethod { .get }

    // MARK: - Headers
    var headers: [RequestHeader] { [.contentJson] }

    // MARK: - Parameters
    var parameters: [String : Any] { [:] }

    // MARK: - Encoding
    var encoding: Encoding { .url }
}
```

#### Request Header

Following Request Headers are implemented, if there is a need for something more, feel free to reach out. Contact you will find on the end of the Readme.

```swift
cookie // Cookie
contentJson // Content-Type: application/json
authBearer(authToken) // Authorization: Bearer [authToken]
```
##### Work in Progess:

* Content-Type: multipart/form-data (also with boundary for images)
* Content-Transfer-Encoding: base64

### Reusable Request
I work with reusable Request so i create a Network class with generics.

#### API Config Struct

```swift
import Foundation
import ZComNet

struct MyAPI {

    // MARK: - Shared
    static let shared = MyAPI()

	// MARK: - Properties    
    private var components: URLComponents {
        var urlComponent = URLComponents()
        urlComponent.scheme = "http"
        urlComponent.host = "127.0.0.1"
        urlComponent.port = 8080
        urlComponent.path = "/api/v1"
        return urlComponent
    }

    // MARK: - API
    var api: ZComNet {
		.init(with: components, loglevel: .debug)
    }
}
```

You can init the ZComNet with a loglevel or you init it without than it is default `none`. You can set the loglevel every time. 

Following example to set the loglevel later with the implementation above:

```swift
MyAPI.shared.api.loglevel = .debug
``` 
#### Request
```swift
import ZComNet

struct Request<T: Codable> {
    func request(_ endpoint: APIEndpoint) async -> Result<T, Error> {
        return await MyAPI.shared.api.request(endpoint, error: ErrorObject.self)
    }
}
```

`ErrorObject.self` is just a Codable struct which you can create. It depends on the API if error is a decodable. You can name this how you want, error takes any Decodable.

#### Requester
```swift
import ZComNet

struct Requester {

    static func request<T: Codable>(_ T: T.Type, endpoint: APIEndpoint) async throws -> T {
        let req = Request<T>()
        let result = await req.request(endpoint)

        switch result {
        case .success(let responseItem): return responseItem
        case .failure(let error): throw error.self
        }
    }
}
```

#### Call in SwiftUI

On Appear call:

```swift
import SwiftUI

struct ContentView: View {

    @State var todos: [TodoRM] = .init()

    var body: some View {
        VStack {
            List(todos, id: \.id) { todo in
                Text(todo.title)
            }
        }
        .onAppear {
            Task {
                guard let todos = try? await Requester.request([TodoRM].self, endpoint: .todos) else { return }
                self.todos = todos
            }
        }
    }
}
```

Or task:

```swift
.task {
	guard let todos = try? await Requester.request([TodoRM].self, endpoint: .todos) else { return }
	self.todos = todos
}
```

### This are just examples how you can use this Framework. Implement it like you want :)

## Contact

[<img src="https://assets-global.website-files.com/6257adef93867e50d84d30e2/636e0a69f118df70ad7828d4_icon_clyde_blurple_RGB.svg" width="80" height="80">](https://discord.gg/27uGafTpJv)
