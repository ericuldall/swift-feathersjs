import Foundation
import JWTDecode

protocol FeathersProvider {
    func setApi (api: FeathersAPI)
    func authenticateLocal (email: String, password: String, complete: @escaping (Bool) throws -> ())
    func build (method: String, service: String, body: NSDictionary?, params: NSDictionary?, complete: @escaping (Data, URLResponse) throws -> (), incomplete: @escaping (Error) throws -> ())
}
