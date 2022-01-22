import Foundation

public class Feathers {
    
    var provider: FeathersProvider = FeathersRestProvider.shared
   
    public var isAuthenticated: Bool {
        return self.provider.isAuthenticated()
    }
    
    public static let shared: Feathers = Feathers()
    
    public init () { return }
    
    func setProvider (provider: FeathersProvider) {
        self.provider = provider
    }
    
    public func setApi (api: FeathersAPI) {
        self.provider.setApi(api: api)
    }
    
    public func authenticate (strategy: String = "local", data: FeathersLocalAuthConfig) async -> Bool {
        if (strategy == "local") {
            do {
                return try await self.provider.authenticateLocal(email: data.email, password: data.password)
            } catch {
                return false
            }
        }
        
        return false
    }
    
    public func preAuth () -> Void {
        if let data = KeychainHelper.standard.read(service: "authentication", account: "jwt") {
            let accessToken = String(decoding: data, as: UTF8.self)
            self.provider.accessToken = accessToken
        }
    }
    
    func getProvider () -> FeathersProvider {
        return self.provider
    }
    
}
