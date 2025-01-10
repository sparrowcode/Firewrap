import Foundation

public enum FirewrapAuthProvider: String, CaseIterable {
    
    case apple
    case google
    case email
    
    public var id: String { rawValue }
    
    static func getByBaseURL(_ url: String) -> FirewrapAuthProvider? {
        for provider in Self.allCases {
            if url == provider.baseURL {
                return provider
            }
        }
        FirewrapAuth.printConsole("Can't get provider by web url \(url)")
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
