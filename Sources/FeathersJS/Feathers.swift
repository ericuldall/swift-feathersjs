import Foundation

class Feathers {
    
    private var provider: FeathersProvider = FeathersRestProvider.shared
    static let shared: Feathers = Feathers()
    
    init () { return }
    
    func setProvider (provider: FeathersProvider) {
        self.provider = provider
    }
    
    func setApi (api: FeathersAPI) {
        self.provider.setApi(api: api)
    }
    
    func authenticate (type: String = "local", data: FeathersLocalAuthConfig, complete: @escaping (Bool) -> ()) {
        if (type == "local") {
            self.provider.authenticateLocal(email: data.email, password: data.password, complete: complete)
        }
    }
    
    func getProvider () -> FeathersProvider {
        return self.provider
    }
    
}
