import Foundation
import Combine

class MotivationalQuoteService {
    //Singleton
    static let shared = MotivationalQuoteService()
    private init() {}

    // MARK: - API Config
    private let apiURL = "https://zenquotes.io/api/random"
}
