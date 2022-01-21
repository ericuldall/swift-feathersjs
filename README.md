# FeathersJS

A Lightweight Feathers.js client for iOS

## Installing
Use xcode package manager and point to this github repo :D

## Getting started in code

*Create your services:*
__Services/Users.swift__
```
import Foundation

struct User: FeathersServiceModel {
    var service: FeathersService? = Users()
    var _id: String?
    var data: NSMutableDictionary? = [
        "email": "",
        "migrated": false
    ]
}

struct Users: FeathersService {    
    var endpoint: String = "/users"
    var model: FeathersServiceModel? = User()
}
```
