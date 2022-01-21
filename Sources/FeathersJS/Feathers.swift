import Foundation

public class Feathers {
    
    var provider: FeathersProvider = FeathersRestProvider.shared
    public static let shared: Feathers = Feathers()
    
    public init () { return }
    
    func setProvider (provider: FeathersProvider) {
        self.provider = provider
    }
    
    public func setApi (api: FeathersAPI) {
        self.provider.setApi(api: api)
    }
    
    public func authenticate (type: String = "local", data: FeathersLocalAuthConfig, complete: @escaping (Bool) -> ()) {
        if (type == "local") {
            self.provider.authenticateLocal(email: data.email, password: data.password, complete: complete)
        }
    }
    
    func getProvider () -> FeathersProvider {
        return self.provider
    }
    
}
