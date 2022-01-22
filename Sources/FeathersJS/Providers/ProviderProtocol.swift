import Foundation
import JWTDecode

protocol FeathersProvider {
    func setApi (api: FeathersAPI)
    func authenticateLocal (email: String, password: String) async throws -> Bool
    func build (method: String, service: String, body: NSDictionary?, params: NSDictionary?) async throws -> FeathersRestResponse
}
