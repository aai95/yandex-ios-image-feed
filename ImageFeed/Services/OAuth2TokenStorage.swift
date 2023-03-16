import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    static let shared = OAuth2TokenStorage()
    
    private enum Keys: String {
        case authToken
    }
    
    private let keychain = KeychainWrapper.standard
    
    private init() {}
    
    var authToken: String? {
        get {
            return keychain.string(forKey: Keys.authToken.rawValue)
        }
        set {
            if let value = newValue {
                keychain.set(value, forKey: Keys.authToken.rawValue)
            }
        }
    }
}
