import Foundation

public enum FirebaseAuthProvider: String, CaseIterable {
    
    case apple
    case google
    case email
    
    public var id: String { rawValue }
    
    static func getByBaseURL(_ url: String) -> FirebaseAuthProvider? {
        for provider in Self.allCases {
            if url == provider.baseURL {
                return provider
            }
        }
        print("FirebaseWrapper: Can't get provider by web url \(url)")
        return nil
    }
    
    var baseURL: String {
        switch self {
        case .apple:
            return "apple.com"
        case .google:
            return "google.com"
        case .email:
            return ""
        }
    }
}
