import Foundation
import JWTDecode

extension URL
{
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

class FeathersRestProvider {
    private var jwt: JWT? = nil
    private var accessToken: String = ""
    private var api: FeathersAPI = FeathersAPI()
    
    static let shared: FeathersRestProvider = FeathersRestProvider()

    init () { return }
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
    
    func setApi (api: FeathersAPI) {
        self.api = api
    }
    
    func build (
        method: String,
        service: String,
        body: NSDictionary? = nil,
        params: NSDictionary? = nil,
        complete: @escaping (Data, URLResponse) throws -> (),
        incomplete: @escaping (Error) throws -> ()
    ) {
        var qs: [String:Any]? = nil
        if (params != nil) {
            if (params!["query"] != nil) {
                qs = params!["query"] as? [String:String]
            }
        }
        let url = URL(string: service, relativeTo: self.api.baseUrl, parameters: qs)!
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = method
        if (body != nil) {
            let bodyData = try? JSONSerialization.data(withJSONObject: body!)
            request.httpBody = bodyData
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        self.sendRequest(request: request, complete: complete, incomplete: incomplete)
    }
    
    
    func authenticateLocal (email: String, password: String, complete: @escaping (Bool) throws -> ()) {
        let body: NSDictionary = [
            "strategy" : "local",
            "email": email,
            "password": password
        ]
        self.build(method: "POST", service: "/authentication", body: body, complete: { (data, response) in
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                self.accessToken = json["accessToken"] as! String
                if (!self.isAuthenticated()) {
                    try? complete(false);
                } else {
                    try? complete(true);
                }
            } catch {
                throw error
            }
        }, incomplete: { error in
            try? complete(false)
        })
    }
    
    func sendRequest (request: URLRequest, complete: @escaping (Data, URLResponse) throws -> (), incomplete: @escaping (Error) throws -> ()) {
        var request = request
        if (self.isAuthenticated()) {
            request.addValue("Bearer \(self.accessToken)", forHTTPHeaderField: "Authorization")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            do {
                if let error = error {
                    try incomplete(error)
                } else if let data = data {
                    do {
                        try complete(data, response!)
                    } catch {
                        try incomplete(error)
                    }
                } else {
                    print("Some other error")
                }
            } catch {
                try? incomplete(error)
            }
        })
        
        task.resume();
    }
}
