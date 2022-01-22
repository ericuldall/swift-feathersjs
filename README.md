# FeathersJS
![Platforms iOS(.v15)](https://img.shields.io/badge/platform-iOS15+-blue?style=for-the-badge)  ![GitHub tag (latest SemVer)](https://img.shields.io/github/v/tag/ericuldall/swift-feathersjs?color=orange&label=VERSION&style=for-the-badge)

A Lightweight Feathers.js client for iOS

## Support Notes
This library is designed for the future and uses async/await to improve code readability
That being said currently this is only tested and support for >= iOS(.v15)

I'm open to acceepting PR's that provide fallback support to `completionHandlers` for other versions
I will also accept PR's to improve support across other devices and provide a more robust experience for users that need it

## Installing
Use xcode package manager and point to this github repo :D

## Getting started in code

*Configure your API:*
__my_appApp.swift__
```
import SwiftUI
import FeathersJS

@main
struct my_appApp: App {
    init () {
        let feathers = Feathers.shared // make reference to Feathers() singleton
        feathers.setApi(api: FeathersAPI(baseUrl: URL(string: "https://myfeathersapi.com")!)) // configure api endpoint
        feathers.preAuth() //load authentication data from keychain
    }
    
    var body: some Scene {
        WindowGroup {
            // You can condtionally show a different initial view based on your auth status
            if (Feathers.shared.isAuthenticated) {
                LoggedInContentView()
            } else {
                LoggedOutContentView()
            }
        }
    }
}

```

*Create your service:*
__Services/Users.swift__
```
import Foundation
import FeathersJS

/**
 * FeathersServiceModel
 *
 * Defines the data model for your service
 * This will hold the response data for an individual entity
 *
 */
struct User: FeathersServiceModel {    
    // Data model defaults, any member of this dict
    // will be stored if returned from the api call
    var data: NSMutableDictionary? = [
        "email": "",
        "firstName": "",
        "lastName": ""
    ]
    
    // Getter for the Service
    func getService () -> FeathersService {
        return Users()
    }
}

/**
 * FeathersService
 *
 * Defines the api endpoint
 * This will be the starting point to interact
 * with the feathers api and get access to models
 *
 */
struct Users: FeathersService {  
    // sets the http endpoint for the model
    var endpoint: String = "/users"
    
    // Getter for the model
    func getModel () -> FeathersServiceModel {
        return User()
    }
}
```

*Call your service:*
```
Task {
    do {
        let users = try await Users().find()
        users.forEach { user in 
            // inspect the User Model
            print(user)
            
            // get only the data from the User Model
            print(try user.get())
            
            // get only the email from the User Model
            print(try user.get(key: "email"))
            
            // change the email in the User Model
            user.set(key: "email", val: "test@test.com")
            
            // save the changes
            _ = user.save() // you can also grab the model returend from the api here (let user = user.save())
        }
    } catch {
        print(error)
    }
}
```

*Authenticate*
__Currently only have local auth implemented__
```
@State private var email: String = ""
@State private var password: String = ""

Task {
    let success = await Feathers.shared.authenticate(
        strategy: "local",
        data: FeathersLocalAuthConfig(
            email: email,
            password: password
        )
    )
}
```
__Note:__ After a successful auth your access token will be stored in memory and automatically passed to all future calls


## Component Details

| Component | Method/Property | Protocol | Description |
|--|--|--|--|
| Feathers | shared | static let shared: Feathers | Singleton access of the Feathers class
| Feathers | setApi | func setApi (api: FeathersAPI) | Initialize your api endpoint
| Feathers | authenticate | func authenticate (strategy: String = "local", data: FeathersLocalAuthConfig) async -> Bool | Call authentication service w/ config
| Feathers | preAuth | func preAuth () -> Void | Load Authentication from keychain if it exists
| Feathers | isAuthenticated | var isAuthenticated: Bool | A computed property of current authentication status
| FeathersService | find | func find (params: NSDictionary?) async throws -> [FeathersServiceModel] | Perform a GET request to `/:self.endpoint`
| FeathersService | get | func get (id: String, params: NSDictionary?) async throws -> FeathersServiceModel | Perform a GET request to `/:self.endpoint/:id`
| FeathersService | create | func create (data: NSDictionary, params: NSDictionary?) async throws -> FeathersServiceModel | Perform a POST request to `/:self.endpoint` with `data` in the request body
| FeathersService | update | func update (id: String, data: NSDictionary, params: NSDictionary?) async throws -> FeathersServiceModel | Perform a PUT request to `/:self.endpoint/:id` with `data` in the request body
| FeathersService | patch | func patch (id: String, data: NSDictionary, params: NSDictionary?) async throws -> FeathersServiceModel | Perform a PATCH request to `/:self.endpoint/:id` with `data` in the request body
| FeathersService | remove | func remove (id: String, params: NSDictionary?) async throws | Perform a DELETE request to `/:self.endpoint/:id`
| FeathersServiceModel | set | func set (key: String, val: **Any**) | Sets `self.data[key] = val`
| FeathersServiceModel | get | func get (key: String?) **throws** -> **Any** | If :key is passed, return key or `throw FeathersServiceModelError.invalidKey` if it doesn't exist. If `key` is **nil** return `self.data`
| FeathersServiceModel | save | func save (params: NSDictionary?) async throws -> FeathersServiceModel | Call `self.service.patch(id: self._id!, data: self.get(), params: params)`
| FeathersServiceModel | remove | func remove (params: NSDictionary?) async throws | Call `self.service.remove(id: self._id!, params: params)`


### Final Notes
This is a very early intro built out of necessity... so look out for more developments. Please contribute to help improve this library

PR's will be promptly reviewed!
