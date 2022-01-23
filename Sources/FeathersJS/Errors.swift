import Foundation

struct FeathersAuthErrorResponse: Error {
    var name: String
    var message: String
    var code: Int
    var className: String
}

enum FeathersJsonError: Error {
    case invalidJSON
}

enum FeathersServiceModelError: Error {
    case invalidKey
    case missingPropertyId
}

enum FeathersRestError: Error {
    case unclassified(message: String)
}
