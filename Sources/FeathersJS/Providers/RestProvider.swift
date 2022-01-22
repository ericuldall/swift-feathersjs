import Foundation
import JWTDecode

public extension URL {
    /// Creates an NSURL with url-encoded parameters.
    init?(string : String, relativeTo: URL?, parameters: [String : Any]? = nil)
    {
        guard var components = URLComponents(string: string) else { return nil }
        if (parameters != nil ) {
            components.queryItems = FeathersHelpers.buildQueryString(parameters: parameters!)
            .components(separatedBy: "&")
            .map {
                $0.components(separatedBy: "=")
            }
            .map {
                return URLQueryItem(name: $0[0], value: $0[1])
            }
        }

        guard let url = components.url else { return nil }

        // Kinda redundant, but we need to call init.
        self.init(string: url.absoluteString, relativeTo: relativeTo)
    }
}

public class FeathersRestProvider {
    private var jwt: JWT? = nil
    private var accessToken: String = ""
    private var api: FeathersAPI = FeathersAPI(baseUrl: nil)
    
    public static let shared: FeathersRestProvider = FeathersRestProvider()

    public init () { return }
}

extension FeathersRestProvider: FeathersProvider {
    func isAuthenticated() -> Bool {
        if (self.accessToken.count > 0) {
            do {
                self.jwt = try decode(jwt: self.accessToken)
                return true
            } catch {
                print("Invalid JWT!")
                self.accessToken = ""
                self.jwt = nil
            }
            return false
        }
        return false
    }
    
    public func setApi (api: FeathersAPI) {
        self.api = api
    }
    
    func build ( method: String, service: String, body: NSDictionary? = nil, params: NSDictionary? = nil ) async throws -> FeathersRestResponse {
        return try await withCheckedThrowingContinuation { continuation in
            var qs: [String:Any]? = nil
            if (params != nil) {
                if (params!["query"] != nil) {
                    qs = params!["query"] as? [String:String]
                }
            }
            let url = URL(string: service, relativeTo: self.api.baseUrl, parameters: qs)!
            var request = URLRequest(url: url)
            request.httpMethod = method
            if (body != nil) {
                let bodyData = try? JSONSerialization.data(withJSONObject: body!)
                request.httpBody = bodyData
            }
            request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            self.sendRequest(request: request, completionHandler: { result in
                continuation.resume(with: result)
            })
        }
    }
    
    
    public func authenticateLocal (email: String, password: String) async throws -> Bool {
        let body: NSDictionary = [
            "strategy" : "local",
            "email": email,
            "password": password
        ]
        do {
            let res = try await self.build(method: "POST", service: "/authentication", body: body)
            let json = try JSONSerialization.jsonObject(with: res.data, options: []) as! [String:Any]
            self.accessToken = json["accessToken"] as? String ?? ""
            if (!self.isAuthenticated()) {
                    return false
            } else {
                    return true
            }
        } catch {
            return false
        }
    }
    
    func sendRequest (request: URLRequest, completionHandler: @escaping (Result<FeathersRestResponse, Error>)->()) {
        var request = request
        if (self.isAuthenticated()) {
            request.addValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                if let error = error {
                    completionHandler(.failure(error))
                } else if let data = data {
                    do {
                        completionHandler(.success(FeathersRestResponse(data: data, response: response!)))
                    } catch {
                        completionHandler(.failure(error))
                    }
                } else {
                    completionHandler(.failure(FeathersRestError.unclassified(message: "An unexpected error occured when trying to access data from the HTTP Request")))
                }
            } catch {
                completionHandler(.failure(error))
            }
        })
        
        task.resume();
    }
}
