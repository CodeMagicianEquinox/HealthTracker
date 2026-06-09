import Foundation

struct MotivationalQuote: Codable {
    let quote: String
    let author: String

    struct APIResponse: Codable {
        let q: String
        let a: String
    }
}
