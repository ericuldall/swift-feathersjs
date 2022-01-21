import Foundation

class FeathersHelpers {
    static func buildQueryString (parameters: [String: Any], arr: Bool? = false) -> String {
        var qs: String = ""

        for (k, v) in parameters {
            // set the key
            if arr! {
                qs = qs + "[" + k + "]"
            } else {
                qs = qs + k
            }
            if let dict = v as? [String: Any] {
                qs = qs + FeathersHelpers.buildQueryString(parameters: dict, arr: true)
            } else {
                qs = qs + "=" + (v as! String)
            }
            qs = qs + "&"
        }
        
        let cs = CharacterSet.init(charactersIn: " &")
        qs = qs.trimmingCharacters(in: cs)
        
        return qs
    }
}
