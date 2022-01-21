import Foundation

protocol FeathersServiceModel {
    var service: FeathersService? { get }
    var _id: String? { get set }
    var data: NSMutableDictionary? { get set }
    
    mutating func populateModel (json: [String: Any])
    mutating func setId (json: [String: Any])
    
    func set (key: String, val: Any)
    func get (key: String?) throws -> Any
    
    func save (params: NSDictionary?, complete: @escaping (FeathersServiceModel) -> (), incomplete: @escaping (Error) -> ())
    func remove (params: NSDictionary?, complete: @escaping () -> (), incomplete: @escaping (Error) -> ())
}

extension FeathersServiceModel {
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
    
    func save (params: NSDictionary? = nil, complete: @escaping (FeathersServiceModel) -> (), incomplete: @escaping (Error) -> ()) {
        self.service!.patch(
            id: self._id!,
            data: try! self.get() as! NSDictionary,
            params: params,
            complete: complete,
            incomplete: incomplete
        )
    }
    
    func remove (params: NSDictionary? = nil, complete: @escaping () -> (), incomplete: @escaping (Error) -> ()) {
        self.service!.remove(
            id: self._id!,
            params: params,
            complete: complete,
            incomplete: incomplete
        )
    }
}

struct FeathersDefaultServiceModel: FeathersServiceModel {
    var service: FeathersService? = nil
    
    var _id: String? = nil
    var data: NSMutableDictionary? = [:]
}

struct FeathersAPI {
    var baseUrl: URL?
    var services: Array<String>?
}

struct FeathersLocalAuthConfig {
    var email: String
    var password: String
}

struct FeathersAuthResponse {
    var _id: String?
    var data: NSMutableDictionary? = [
        "accessToken": "",
        "authentication": [:],
        "user": [:]
    ]
}

extension FeathersAuthResponse: FeathersServiceModel {
    var service: FeathersService? {
        return nil
    }
    
    init (json: [String: Any]) {
        self.data!["accessToken"] = json["accessToken"]
        self.data!["authentication"] = json["authentication"]
        self.data!["user"] = json["user"]
    }
}

protocol FeathersService {
    var endpoint: String { get set }
    var model: FeathersServiceModel? { get }
    
    func find (params: NSDictionary?, complete: @escaping ([FeathersServiceModel])->(), incomplete: @escaping (Error) -> ())
    func get (id: String, params: NSDictionary?, complete: @escaping (FeathersServiceModel)->(), incomplete: @escaping (Error) -> ())
    func create (data: NSDictionary, params: NSDictionary?, complete: @escaping (FeathersServiceModel)->(), incomplete: @escaping (Error) -> ())
    func update (id: String, data: NSDictionary, params: NSDictionary?, complete: @escaping (FeathersServiceModel)->(), incomplete: @escaping (Error) -> ())
    func patch (id: String, data: NSDictionary, params: NSDictionary?, complete: @escaping (FeathersServiceModel)->(), incomplete: @escaping (Error) -> ())
    func remove (id: String, params: NSDictionary?, complete: @escaping ()->(), incomplete: @escaping (Error) -> ())
}

extension FeathersService {
    var model: FeathersServiceModel? {
        return nil
    }
    
    func find(
        params: NSDictionary? = nil,
        complete: @escaping ([FeathersServiceModel])->(),
        incomplete: @escaping (Error) -> ()
    ) {
        Feathers
            .shared
            .getProvider()
            .build(
                method: "GET",
                service: self.endpoint,
                body: nil,
                params: params,
                complete: { (data, response) in
                    do {
                        let items: NSMutableArray = []
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        let data = json["data"] as! NSArray
                        data.forEach { item in
                            let item = item as! [String:Any]
                            var model = self.model!
                            model.setId(json: item)
                            model.populateModel(json: item)
                            items.add(model)
                        }
                        complete(items as! [FeathersServiceModel])
                    } catch {
                        throw FeathersJsonError.invalidJSON
                    }
                }, incomplete: { error in
            
                }
            )
    }
    
    func get (
        id: String,
        params: NSDictionary? = nil,
        complete: @escaping (FeathersServiceModel)->(),
        incomplete: @escaping (Error) -> ()
    ) {
        Feathers
            .shared
            .getProvider()
            .build(
                method: "GET",
                service: String(format:"%@/%@", self.endpoint, id),
                body: nil,
                params: nil,
                complete: { (data, response) in
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        var model = self.model!
                            model.setId(json: json)
                            model.populateModel(json: json)
                        complete(model)
                    } catch {
                        throw FeathersJsonError.invalidJSON
                    }
                }, incomplete: { error in
            
                }
            )
    }
    
    func create (
        data: NSDictionary,
        params: NSDictionary?,
        complete: @escaping (FeathersServiceModel)->(),
        incomplete: @escaping (Error) -> ()
    ) {
        Feathers
            .shared
            .getProvider()
            .build(
                method: "POST",
                service: self.endpoint,
                body: data,
                params: params,
                complete: { (data, response) in
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        var model = self.model!
                            model.setId(json: json)
                            model.populateModel(json: json)
                        complete(model)
                    } catch {
                        throw FeathersJsonError.invalidJSON
                    }
                }, incomplete: { error in
                    incomplete(error)
                }
            )
    }
    
    func update (
        id: String,
        data: NSDictionary,
        params: NSDictionary?,
        complete: @escaping (FeathersServiceModel)->(),
        incomplete: @escaping (Error) -> ()
    ) {
        Feathers
            .shared
            .getProvider()
            .build(
                method: "PUT",
                service: String(format:"%@/%@", self.endpoint, id),
                body: data,
                params: params,
                complete: { (data, response) in
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        var model = self.model!
                            model.setId(json: json)
                            model.populateModel(json: json)
                        complete(model)
                    } catch {
                        throw FeathersJsonError.invalidJSON
                    }
                }, incomplete: { error in
                    incomplete(error)
                }
            )
    }
    
    func patch (
        id: String,
        data: NSDictionary,
        params: NSDictionary?,
        complete: @escaping (FeathersServiceModel)->(),
        incomplete: @escaping (Error) -> ()
    )  {
        Feathers
            .shared
            .getProvider()
            .build(
                method: "PATCH",
                service: String(format:"%@/%@", self.endpoint, id),
                body: data,
                params: params,
                complete: { (data, response) in
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        var model = self.model!
                            model.setId(json: json)
                            model.populateModel(json: json)
                        complete(model)
                    } catch {
                        throw FeathersJsonError.invalidJSON
                    }
                }, incomplete: { error in
                    incomplete(error)
                }
            )
    }
    
    func remove (
        id: String,
        params: NSDictionary?,
        complete: @escaping ()->(),
        incomplete: @escaping (Error) -> ()
    )  {
        Feathers
            .shared
            .getProvider()
            .build(
                method: "DELETE",
                service: String(format:"%@/%@", self.endpoint, id),
                body: nil,
                params: params,
                complete: { (data, response) in
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        var model = self.model!
                            model.setId(json: json)
                            model.populateModel(json: json)
                        complete()
                    } catch {
                        throw FeathersJsonError.invalidJSON
                    }
                }, incomplete: { error in
                    incomplete(error)
                }
            )
    }
}

struct FeathersDefaultService: FeathersService {
    var endpoint: String
    var model: FeathersServiceModel? = FeathersDefaultServiceModel()
}
