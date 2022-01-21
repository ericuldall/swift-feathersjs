# FeathersJS

A Lightweight Feathers.js client for iOS

## Installing
Use xcode package manager and point to this github repo :D

## Getting started in code

*Create your services:*
__Services/Users.swift__
```
import Foundation

// Define your user model
struct User: FeathersServiceModel {
    // Reference to the related service
    var service: FeathersService? = Users()
    var data: NSMutableDictionary? = [
        "email": "",
        "firstName": "",
        "lastName": ""
    ]
}

struct Users: FeathersService {    
    var endpoint: String = "/users"
    var model: FeathersServiceModel? = User()
}
```
