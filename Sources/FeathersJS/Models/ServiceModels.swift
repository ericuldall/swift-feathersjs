import Foundation
import UIKit
import Combine

public protocol FeathersServiceModel {
    var _id: String? { get set }
    var data: NSMutableDictionary? { get set }
    
    func getService () -> FeathersService
    
    mutating func populateModel (json: [String: Any])
    mutating func setId (json: [String: Any])
    
    func set (key: String, val: Any)
    func get (key: String?) throws -> Any
    
    func save (params: NSDictionary?) async throws -> FeathersServiceModel
    func remove (params: NSDictionary?) async throws
}

public extension FeathersServiceModel {
    mutating func populateModel (json: [String: Any]) {
        for (key, val) in json {
            self.set(key: key, val: val)
        }
        return
    }
    
    mutating func setId (json: [String: Any]) {
        self._id = (json["_id"] as! String)
    }
    
    func set (key: String, val: Any) {
        if (self.data![key] != nil) {
            self.data![key] = val
        }
    }
    
    func get (key: String? = nil) throws -> Any {
        if (key != nil) {
            if let val = self.data![key!] {
                return val
            }
            throw FeathersServiceModelError.invalidKey
        }
        
        return self.data!
    }
    
    func save (params: NSDictionary? = nil) async throws -> FeathersServiceModel {
        return try await self.getService().patch(
            id: self._id!,
            data: try! self.get() as! NSDictionary,
            params: params
        )
    }
    
    func remove (params: NSDictionary? = nil) async throws {
        return try await self.getService().remove(
            id: self._id!,
            params: params
        )
    }
}

struct FeathersDefaultServiceModel: FeathersServiceModel {
    var _id: String? = nil
    public var data: NSMutableDictionary? = [:]
    
    func getService() -> FeathersService {
        return FeathersDefaultService()
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

public struct FeathersAuthResponse {
    public var _id: String?
    public var data: NSMutableDictionary? = [
        "accessToken": "",
        "authentication": [:],
        "user": [:]
    ]
    
    public func getService() -> FeathersService {
        return FeathersDefaultService()
    }
}

extension FeathersAuthResponse: FeathersServiceModel {
    init (json: [String: Any]) {
        self.data!["accessToken"] = json["accessToken"]
        self.data!["authentication"] = json["authentication"]
        self.data!["user"] = json["user"]
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
                var model = self.getModel()
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
            var model = self.getModel()
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
            var model = self.getModel()
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
            var model = self.getModel()
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
            var model = self.getModel()
                model.setId(json: json)
                model.populateModel(json: json)
            return model
        } catch {
            throw FeathersJsonError.invalidJSON
        }
    }
    
    func remove (id: String, params: NSDictionary?) async throws  {
        try await Feathers.shared.getProvider().build(method: "DELETE", service: String(format:"%@/%@", self.endpoint!, id), body: nil, params: nil)
    }
}

struct FeathersDefaultService: FeathersService {
    var endpoint: String?
    
    func getModel() -> FeathersServiceModel {
        return FeathersDefaultServiceModel()
    }
}
