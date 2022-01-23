import Foundation
import UIKit
import Combine

public protocol FeathersServiceModelProtocol: Identifiable {
    func getService () -> FeathersService
    
    func populateModel (json: [String: Any])
    func setId (json: [String: Any])
    
    func set (key: String, val: Any)
    func get (key: String?) throws -> Any
    
    func save (params: NSDictionary?) async throws -> FeathersServiceModel
    func remove (params: NSDictionary?) async throws
}

open class FeathersServiceModel: FeathersServiceModelProtocol {
    public var id: String?
    var data: NSMutableDictionary?
    
    public init (data: NSMutableDictionary) {
        self.data = data
    }
    
    open func getService() -> FeathersService {
        return FeathersDefaultService()
    }

    public func populateModel (json: [String: Any]) {
        for (key, val) in json {
            self.set(key: key, val: val)
        }
        return
    }
    
    public func setId (json: [String: Any]) {
        self.id = (json["_id"] as! String)
    }
    
    public func set (key: String, val: Any) {
        if (self.data![key] != nil) {
            self.data![key] = val
        }
    }
    
    public func get (key: String? = nil) throws -> Any {
        if (key != nil) {
            if let val = self.data![key!] {
                return val
            }
            throw FeathersServiceModelError.invalidKey
        }
        
        return self.data!
    }
    
    public func save (params: NSDictionary? = nil) async throws -> FeathersServiceModel {
        if (self.id == nil) {
            return try await self.getService().create(
                data: try! self.get() as! NSDictionary,
                params: params
            )
        } else {
            return try await self.getService().patch(
                id: self.id!,
                data: try! self.get() as! NSDictionary,
                params: params
            )
        }
    }
    
    public func remove (params: NSDictionary? = nil) async throws {
        if (id == nil) {
            throw FeathersServiceModelError.missingPropertyId
        }
        return try await self.getService().remove(
            id: self.id!,
            params: params
        )
    }
}

public struct FeathersAPI {
    var baseUrl: URL?
    
    public init (baseUrl: URL?) {
        self.baseUrl = baseUrl
    }
}

public struct FeathersLocalAuthConfig {
    public var email: String
    public var password: String
    
    public init (email: String, password: String) {
        self.email = email
        self.password = password
    }
}

public protocol FeathersService {
    var endpoint: String? { get set }
    func getModel () -> FeathersServiceModel
    
    func find (params: NSDictionary?) async throws -> [FeathersServiceModel]
    func get (id: String, params: NSDictionary?) async throws -> FeathersServiceModel
    func create (data: NSDictionary, params: NSDictionary?) async throws -> FeathersServiceModel
    func update (id: String, data: NSDictionary, params: NSDictionary?) async throws -> FeathersServiceModel
    func patch (id: String, data: NSDictionary, params: NSDictionary?) async throws -> FeathersServiceModel
    func remove (id: String, params: NSDictionary?) async throws
}

public extension FeathersService {
    func find(params: NSDictionary? = nil) async throws -> [FeathersServiceModel] {
        do {
            let res = try await Feathers.shared.getProvider().build(method: "GET", service: self.endpoint!, body: nil, params: params)
            let items: NSMutableArray = []
            let json = try JSONSerialization.jsonObject(with: res.data, options: []) as! [String:Any]
            let data = json["data"] as! NSArray
            data.forEach { item in
                let item = item as! [String:Any]
                let model = self.getModel()
                    model.setId(json: item)
                    model.populateModel(json: item)
                items.add(model)
            }
            return items as! [FeathersServiceModel]
        } catch {
            throw FeathersJsonError.invalidJSON
        }
    }
    
    func get (id: String, params: NSDictionary? = nil) async throws -> FeathersServiceModel {
        let res = try await Feathers.shared.getProvider().build(method: "GET", service: String(format:"%@/%@", self.endpoint!, id), body: nil, params: nil)
        do {
            let json = try JSONSerialization.jsonObject(with: res.data, options: []) as! [String:Any]
            let model = self.getModel()
                model.setId(json: json)
                model.populateModel(json: json)
            return model
        } catch {
            throw FeathersJsonError.invalidJSON
        }
    }
    
    func create (data: NSDictionary, params: NSDictionary?) async throws -> FeathersServiceModel {
        let res = try await Feathers.shared.getProvider().build(method: "POST", service: self.endpoint!, body: nil, params: nil)
        do {
            let json = try JSONSerialization.jsonObject(with: res.data, options: []) as! [String:Any]
            let model = self.getModel()
                model.setId(json: json)
                model.populateModel(json: json)
            return model
        } catch {
            throw FeathersJsonError.invalidJSON
        }
    }
    
    func update (id: String, data: NSDictionary, params: NSDictionary?) async throws -> FeathersServiceModel {
        let res = try await Feathers.shared.getProvider().build(method: "PUT", service: String(format:"%@/%@", self.endpoint!, id), body: data, params: nil)
        do {
            let json = try JSONSerialization.jsonObject(with: res.data, options: []) as! [String:Any]
            let model = self.getModel()
                model.setId(json: json)
                model.populateModel(json: json)
            return model
        } catch {
            throw FeathersJsonError.invalidJSON
        }
    }
    
    func patch (id: String, data: NSDictionary, params: NSDictionary?) async throws -> FeathersServiceModel  {
        let res = try await Feathers.shared.getProvider().build(method: "PATCH", service: String(format:"%@/%@", self.endpoint!, id), body: data, params: nil)
        do {
            let json = try JSONSerialization.jsonObject(with: res.data, options: []) as! [String:Any]
            let model = self.getModel()
                model.setId(json: json)
                model.populateModel(json: json)
            return model
        } catch {
            throw FeathersJsonError.invalidJSON
        }
    }
    
    func remove (id: String, params: NSDictionary?) async throws  {
        _ = try await Feathers.shared.getProvider().build(method: "DELETE", service: String(format:"%@/%@", self.endpoint!, id), body: nil, params: nil)
    }
}

struct FeathersDefaultService: FeathersService {
    var endpoint: String?
    
    func getModel() -> FeathersServiceModel {
        return FeathersServiceModel(data: [:])
    }
}
