# FeathersJS

A Lightweight Feathers.js client for iOS

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
        let feathers = Feathers.shared
        feathers.setApi(api: FeathersAPI(baseUrl: URL(string: "https://myfeathersapi.com")!))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
    Users().find(
        complete: { models in // we end up here if everything went good :D
            models.forEach { user in 
                // inspect the User Model
                print(user)
                
                // get only the data from the User Model
                print(user.get())
                
                // get only the email from the User Model
                print(user.get(key: "email"))
                
                // change the email in the User Model
                user.set(key: "email", val: "test@test.com")
                // save the changes
                user.save(
                    complete: { user in
                        // we have access to the updated model from the api here
                    },
                    incomplete: { error in
                        print(error)
                    }
                )
            }
        },
        incomplete: { error in // we end up here if something failed
            print(error)
        }
    )
```

*Authenticate*
__Currently only have local auth implemented__
```
Feathers.shared.authenticate(
    type: "local",
    data: FeathersLocalAuthConfig(
        email: email,
        password: password
    ),
    complete: { success in
        print(success) // return a Bool to tell you if auth was successful or not
    }
)
```
__Note:__ After a successful auth your access token will be stored in memory and automatically passed to all future calls


## Component Details

| Component | Method | Protocol | Description |
|--|--|--|--|
| FeathersService | find | find (params: NSDictionary?, complete: **@escaping** ([FeathersServiceModel])->(), incomplete: **@escaping** (Error) -> ()) | Perform a GET request to `/:self.endpoint`
| FeathersService | get | get (id: String, params: NSDictionary?, complete: **@escaping** (FeathersServiceModel)->(), incomplete: **@escaping** (Error) -> ()) | Perform a GET request to `/:self.endpoint/:id`
| FeathersService | create | create (data: NSDictionary, params: NSDictionary?, complete: **@escaping** (FeathersServiceModel)->(), incomplete: **@escaping** (Error) -> ()) | Perform a POST request to `/:self.endpoint` with `data` in the request body
| FeathersService | update | update (id: String, data: NSDictionary, params: NSDictionary?, complete: **@escaping** (FeathersServiceModel)->(), incomplete: **@escaping** (Error) -> ()) | Perform a PUT request to `/:self.endpoint/:id` with `data` in the request body
| FeathersService | patch | patch (id: String, data: NSDictionary, params: NSDictionary?, complete: **@escaping** (FeathersServiceModel)->(), incomplete: **@escaping** (Error) -> ()) | Perform a PATCH request to `/:self.endpoint/:id` with `data` in the request body
| FeathersService | remove | remove (id: String, params: NSDictionary?, complete: **@escaping** ()->(), incomplete: **@escaping** (Error) -> ()) | Perform a DELETE request to `/:self.endpoint/:id`
| FeathersServiceModel | set | set (key: String, val: **Any**) | Sets `self.data[key] = val`
| FeathersServiceModel | get | get (key: String?) **throws** -> **Any** | If :key is passed, return key or `throw FeathersServiceModelError.invalidKey` if it doesn't exist. If `key` is **nil** return `self.data`
| FeathersServiceModel | save | save (params: NSDictionary?, complete: **@escaping** (FeathersServiceModel) -> (), incomplete: **@escaping** (Error) -> ()) | Call `self.service.patch(id: self._id!, data: self.get(), params: params, complete: complete, incomplete: incomplete)`
| FeathersServiceModel | remove | remove (params: NSDictionary?, complete: **@escaping** () -> (), incomplete: **@escaping** (Error) -> ()) | Call `self.service.remove(id: self._id!, params: params, complete: complete, incomplete: incomplete)`


### Final Notes
This is a very early intro built out of necessity... so look out for more developments. Please contribute to help improve this library

PR's will be promptly reviewed!
